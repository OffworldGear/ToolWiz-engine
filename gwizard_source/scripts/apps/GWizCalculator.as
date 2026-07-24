package apps
{
   import comps.GWizPanel;
   import comps.skins.PanelSkin;
   import configinfo.GWizSettings;
   import flash.display.NativeWindowSystemChrome;
   import flash.display.NativeWindowType;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import login.GWizCredentials;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.containers.ViewStack;
   import mx.controls.Spacer;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.FlexGlobals;
   import mx.core.IFlexModuleFactory;
   import mx.core.UIComponentDescriptor;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.IndexChangedEvent;
   import mx.events.PropertyChangeEvent;
   import mx.formatters.NumberBase;
   import mx.formatters.NumberBaseRoundType;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.skins.ProgrammaticSkin;
   import mx.styles.CSSCondition;
   import mx.styles.CSSSelector;
   import mx.styles.CSSStyleDeclaration;
   import skins.GWizAccordionHeaderSkin;
   import spark.components.Button;
   import spark.components.ButtonBar;
   import spark.components.DropDownList;
   import spark.components.Group;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NavigatorContent;
   import spark.components.NumericStepper;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.components.Window;
   import spark.layouts.VerticalLayout;
   import spark.primitives.Line;
   import spark.primitives.Rect;
   import utils.GWizUtils;
   import views.GWizAngleChooser;
   import views.GWizFracChooser;
   import views.GWizUnitChooser;
   
   use namespace mx_internal;
   
   public class GWizCalculator extends GWizPanel implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCalculator");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1965657632Angles:NavigatorContent;
      
      private var _125797517CalcDisplay:TextInput;
      
      private var _1711531860CalcOpDisplay:Label;
      
      private var _1678723693Convert:NavigatorContent;
      
      private var _2615356Trig:NavigatorContent;
      
      public var _GWizCalculator_Button18:Button;
      
      public var _GWizCalculator_ButtonBar1:ButtonBar;
      
      public var _GWizCalculator_ButtonBar2:ButtonBar;
      
      public var _GWizCalculator_GWizAngleChooser1:GWizAngleChooser;
      
      private var _3118c1:Label;
      
      private var _3119c2:Label;
      
      private var _609849998conversionPanel:GWizUnitChooser;
      
      private var _1978768951detachBtn:Button;
      
      private var _1198113074featureStack:ViewStack;
      
      private var _607583858fracBtn:GWizFracChooser;
      
      private var _3428m1:Label;
      
      private var _3429m2:Label;
      
      private var _631229717unitConvResult:TextInput;
      
      private var _292652322unitType:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var disableShowUnits:Boolean = false;
      
      private var gotOp:Boolean = false;
      
      private var CalcWin:Window;
      
      private var _479015106attachImg:Class;
      
      private var _1978762448detachImg:Class;
      
      private const radDegLabels:ArrayList = new ArrayList([this.RAD,this.DEG]);
      
      private var oldValue:String = "";
      
      private var point1:Point;
      
      private var cfPrivateDisplay:String = "";
      
      public var cfDispVal:Number = 0.0;
      
      private var _1243406391cfQueuedOp:String = "";
      
      private var cfQueuedVal:Number = 0.0;
      
      private var cfInMMState:String = "Inches";
      
      private const MAX_CFDISP_CHARS:int = 20;
      
      private const RADIANS_MODE:int = 0;
      
      private const DEGREES_MODE:int = 1;
      
      private var degMode:int = 0;
      
      private var _750927705clearLabel:String = "AC";
      
      public const AC:String = "AC";
      
      public const ACOS:String = "ACOS";
      
      public const ASIN:String = "ASIN";
      
      public const ATAN:String = "ATAN";
      
      public const BKSP:String = "BKSP";
      
      public const CLX:String = "CLx";
      
      public const COS:String = "COS";
      
      public const DEG:String = "Deg";
      
      public const E:String = "e";
      
      public const I:String = "I";
      
      public const INV:String = "1/x";
      
      public const LN:String = "ln";
      
      public const M:String = "M";
      
      public const NEG:String = "-";
      
      public const PCT:String = "Pct";
      
      public const PI:String = "Pi";
      
      public const RAD:String = "Rad";
      
      public const SIN:String = "SIN";
      
      public const SQR:String = "x^2";
      
      public const SQRT:String = "SQRT";
      
      public const TAN:String = "TAN";
      
      public const TENTHS:String = "TENTHS";
      
      public const THOUS:String = "THOUS";
      
      mx_internal var _GWizCalculator_StylesInit_done:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCalculator()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._479015106attachImg = GWizCalculator_attachImg;
         this._1978762448detachImg = GWizCalculator_detachImg;
         this.point1 = new Point();
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCalculator_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_apps_GWizCalculatorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCalculator[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.darkBack = true;
         this.backgroundAlpha = 1;
         this.layout = this._GWizCalculator_VerticalLayout1_c();
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizCalculator_Array1_c);
         this.addEventListener("creationComplete",this.___GWizCalculator_GWizPanel1_creationComplete);
         this.addEventListener("show",this.___GWizCalculator_GWizPanel1_show);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCalculator._watcherSetupUtil = param1;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.skinClass = PanelSkin;
         };
         mx_internal::_GWizCalculator_StylesInit();
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function tearOffCalc() : void
      {
         var _loc1_:GWizCalculator = null;
         if(this.CalcWin != null)
         {
            removeEventListener(FocusEvent.FOCUS_IN,this.windowFocusChange);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            removeEventListener(Event.DEACTIVATE,this.onAppDeactivate);
            removeEventListener(Event.ACTIVATE,this.onAppActivate);
            this.CalcWin.close();
            this.CalcWin.removeAllElements();
            this.detachBtn.setStyle("icon",this.detachImg);
            FlexGlobals.topLevelApplication.attachCalculator(this);
            this.CalcWin = null;
         }
         else
         {
            this.CalcWin = new Window();
            _loc1_ = FlexGlobals.topLevelApplication.detachCalculator();
            this.CalcWin.addElement(_loc1_);
            _loc1_.x = 0;
            _loc1_.y = 0;
            this.CalcWin.width = _loc1_.width;
            this.CalcWin.height = _loc1_.height;
            this.CalcWin.transparent = true;
            this.CalcWin.alwaysInFront = true;
            this.CalcWin.showStatusBar = false;
            this.CalcWin.resizable = false;
            this.CalcWin.type = NativeWindowType.LIGHTWEIGHT;
            this.CalcWin.systemChrome = NativeWindowSystemChrome.NONE;
            this.CalcWin.setStyle("showFlexChrome",false);
            this.detachBtn.setStyle("icon",this.attachImg);
            this.CalcWin.open();
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            addEventListener(FocusEvent.FOCUS_IN,this.windowFocusChange);
            addEventListener(Event.DEACTIVATE,this.onAppDeactivate);
            addEventListener(Event.ACTIVATE,this.onAppActivate);
         }
      }
      
      private function onAppDeactivate(param1:Event) : void
      {
         this.CalcWin.alwaysInFront = false;
      }
      
      private function onAppActivate(param1:Event) : void
      {
         this.CalcWin.alwaysInFront = true;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(param1.target is UITextField)
         {
            return;
         }
         stage.nativeWindow.startMove();
      }
      
      private function valueChanged(param1:Event) : void
      {
         if(this.oldValue != this.CalcDisplay.text)
         {
            this.oldValue = this.CalcDisplay.text;
            this.showUnits(param1);
         }
      }
      
      private function showUnits(param1:Event) : void
      {
         if(this.disableShowUnits)
         {
            return;
         }
         this.disableShowUnits = true;
         this.unitConvResult.text = String(this.convertUnits(this.cfDispVal));
         var _loc2_:String = GWizUtils.dec2Fraction(this.cfDispVal,0.001);
         if(_loc2_.length == 0)
         {
            this.fracBtn.label = "Fract.";
         }
         else
         {
            this.fracBtn.label = _loc2_;
         }
         this.disableShowUnits = false;
         this.callLater(this.restoreFocus);
      }
      
      private function windowFocusChange(param1:Event) : void
      {
         var _loc2_:Object = focusManager.getFocus();
         if(_loc2_ != null && (_loc2_ is TextInput || _loc2_ is NumericStepper || _loc2_ is DropDownList))
         {
            return;
         }
         this.CalcDisplay.setFocus();
         this.CalcDisplay.selectRange(this.CalcDisplay.text.length,this.CalcDisplay.text.length);
      }
      
      public function restoreFocus() : void
      {
         var _loc1_:String = null;
         if(GWizUtils.currApp != "Calculator")
         {
            return;
         }
         this.detachBtn.enabled = GWizCredentials.isGWLite() || GWizSettings.loginBar.CheckSecurity();
         this.CalcDisplay.setFocus();
         this.CalcDisplay.selectRange(this.CalcDisplay.text.length,this.CalcDisplay.text.length);
         log.debug("restoreFocus, currApp == " + GWizUtils.currApp);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc2_:int = 8;
         var _loc3_:int = 13;
         var _loc4_:String = String.fromCharCode(param1.charCode);
         if(param1.charCode == _loc2_)
         {
            this.cfPostfixOp(this.BKSP);
         }
         else if(!param1.ctrlKey)
         {
            param1.preventDefault();
            switch(_loc4_)
            {
               case "+":
                  this.cfPlusBtn();
                  this.gotOp = true;
                  break;
               case "-":
                  this.cfSubtractBtn();
                  this.gotOp = true;
                  break;
               case "*":
                  log.debug("onKeyDown: cfMultiplyBtn");
                  this.cfMultiplyBtn();
                  this.gotOp = true;
                  break;
               case "/":
                  this.cfDivideBtn();
                  this.gotOp = true;
                  break;
               case "=":
                  this.cfEqualsBtn();
                  this.CalcDisplay.text = String(this.setPrecision(Number(this.cfDisplay),15));
                  break;
               case "%":
                  this.cfPostfixOp(this.PCT);
                  break;
               case ".":
                  if(this.CalcDisplay.text.indexOf(".") == -1)
                  {
                     this.CalcDisplay.text += ".";
                  }
                  break;
               case "i":
               case "I":
                  this.cfPostfixOp(this.I);
                  break;
               case "m":
               case "M":
                  this.cfPostfixOp(this.M);
                  break;
               default:
                  if("0" <= _loc4_ && _loc4_ <= "9")
                  {
                     if(this.CalcDisplay.selectionActivePosition != this.CalcDisplay.selectionAnchorPosition)
                     {
                        _loc5_ = this.CalcDisplay.selectionActivePosition < this.CalcDisplay.selectionAnchorPosition ? int(this.CalcDisplay.selectionActivePosition) : int(this.CalcDisplay.selectionAnchorPosition);
                        _loc6_ = this.CalcDisplay.selectionActivePosition > this.CalcDisplay.selectionAnchorPosition ? int(this.CalcDisplay.selectionActivePosition) : int(this.CalcDisplay.selectionAnchorPosition);
                        log.debug("Replacing selection...");
                        _loc7_ = this.CalcDisplay.text.substr(0,_loc5_) + _loc4_ + this.CalcDisplay.text.substr(_loc6_,this.CalcDisplay.text.length - _loc6_);
                        this.cfDisplay = this.CalcDisplay.text = _loc7_;
                        this.CalcDisplay.selectRange(_loc6_ - 1,_loc6_ - 1);
                        this.cfDispVal = Number(this.cfDisplay);
                     }
                     else
                     {
                        this.cfAddDigit(_loc4_);
                        this.CalcDisplay.text = this.cfDisplay;
                     }
                  }
                  else if(param1.charCode == _loc3_)
                  {
                     this.cfEqualsBtn();
                     this.CalcDisplay.text = String(this.setPrecision(Number(this.cfDisplay),15));
                  }
            }
         }
      }
      
      private function convertUnits(param1:Number) : Number
      {
         var _loc2_:Number = 8;
         var _loc3_:Number = param1;
         _loc3_ = (param1 + Number(this.c1.text)) * Number(this.m1.text);
         return Number(GWizUtils.roundPlaces(_loc3_ / Number(this.m2.text) - Number(this.c2.text),_loc2_));
      }
      
      private function doUseValue() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         this.disableShowUnits = true;
         _loc4_ = this.c1.text;
         this.c1.text = this.c2.text;
         this.c2.text = _loc4_;
         _loc5_ = this.m1.text;
         this.m1.text = this.m2.text;
         this.m2.text = _loc5_;
         _loc1_ = this.CalcDisplay.text;
         _loc2_ = this.unitConvResult.text;
         this.cfDisplay = _loc2_;
         this.CalcDisplay.text = _loc2_;
         this.unitConvResult.text = _loc1_;
         this.conversionPanel.swapUnits();
         this.CalcDisplay.setFocus();
         this.CalcDisplay.selectRange(this.CalcDisplay.text.length,this.CalcDisplay.text.length);
         this.disableShowUnits = false;
      }
      
      private function cfQueueOp(param1:String) : void
      {
         log.debug("cfQueueOp: " + param1);
         if(this.cfQueuedOp.length != 0)
         {
            this.cfEvalQueuedOp();
         }
         this.cfQueuedOp = param1;
         this.cfQueuedVal = this.cfDispVal;
         this.cfDisplay = "";
         this.cfDispVal = 0;
      }
      
      private function setPrecision(param1:Number, param2:int) : Number
      {
         param2 = Math.pow(10,param2);
         return Math.round(param1 * param2) / param2;
      }
      
      private function set _2129887521cfDisplay(param1:String) : void
      {
         this.cfPrivateDisplay = param1;
         this.cfDispVal = Number(this.cfPrivateDisplay);
      }
      
      public function get cfDisplay() : String
      {
         return this.cfPrivateDisplay;
      }
      
      private function pressedClear() : void
      {
         if(this.clearLabel == "CLx")
         {
            this.clearLabel = "AC";
            this.cfPostfixOp(this.CLX);
         }
         else
         {
            this.cfPostfixOp(this.AC);
         }
         this.restoreFocus();
      }
      
      public function cfAddDigit(param1:String, param2:Boolean = false) : void
      {
         if(this.cfQueuedOp == "=")
         {
            this.cfQueuedOp = "";
            this.cfDisplay = param1;
            this.cfDispVal = Number(this.cfDisplay);
         }
         else if(this.cfDisplay.length < this.MAX_CFDISP_CHARS && !param2)
         {
            this.cfDisplay += param1;
            this.cfDispVal = Number(this.cfDisplay);
         }
         this.clearLabel = "CLx";
      }
      
      public function cfXtoYBtn() : void
      {
         this.cfQueueOp("XtoY");
      }
      
      public function cfMultiplyBtn() : void
      {
         log.debug("cfMultiplyBtn");
         this.cfQueueOp("x");
      }
      
      public function cfDivideBtn() : void
      {
         this.cfQueueOp("÷");
      }
      
      public function cfPlusBtn() : void
      {
         this.cfQueueOp("+");
      }
      
      public function cfSubtractBtn() : void
      {
         this.cfQueueOp("-");
      }
      
      public function cfDecimalBtn() : void
      {
         if(this.cfDisplay.indexOf(".",0) == -1)
         {
            this.cfAddDigit(".");
         }
         else if(this.cfQueuedOp == "=")
         {
            this.cfAddDigit(".");
         }
      }
      
      public function cfEvalQueuedOp() : void
      {
         switch(this.cfQueuedOp)
         {
            case "x":
               this.cfDispVal = this.cfQueuedVal * this.cfDispVal;
               break;
            case "÷":
               this.cfDispVal = this.cfQueuedVal / this.cfDispVal;
               break;
            case "+":
               this.cfDispVal = this.cfQueuedVal + this.cfDispVal;
               break;
            case "-":
               this.cfDispVal = this.cfQueuedVal - this.cfDispVal;
               break;
            case "XtoY":
               this.cfDispVal = Math.pow(this.cfQueuedVal,this.cfDispVal);
               break;
            default:
               log.debug("Bad op error: " + this.cfQueuedOp);
               return;
         }
         this.cfDisplay = String(this.setPrecision(this.cfDispVal,15));
      }
      
      public function cfEqualsBtn() : void
      {
         if(this.cfQueuedOp.length > 0)
         {
            this.cfEvalQueuedOp();
            this.cfQueuedOp = "=";
         }
      }
      
      public function cfPostfixOp(param1:String) : void
      {
         var _loc2_:NumberBase = new NumberBase();
         var _loc3_:Boolean = false;
         switch(param1)
         {
            case this.ACOS:
               this.cfDispVal = Math.acos(this.cfDispVal);
               if(this.degMode == this.DEGREES_MODE)
               {
                  this.cfDispVal = GWizUtils.degrees(this.cfDispVal);
               }
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.ASIN:
               this.cfDispVal = Math.asin(this.cfDispVal);
               if(this.degMode == this.DEGREES_MODE)
               {
                  this.cfDispVal = GWizUtils.degrees(this.cfDispVal);
               }
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.ATAN:
               this.cfDispVal = Math.atan(this.cfDispVal);
               if(this.degMode == this.DEGREES_MODE)
               {
                  this.cfDispVal = GWizUtils.degrees(this.cfDispVal);
               }
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.BKSP:
               if(this.cfDisplay.length > 0)
               {
                  this.cfDisplay = this.cfDisplay.substr(0,this.cfDisplay.length - 1);
                  this.cfDispVal = Number(this.cfDisplay);
               }
               _loc3_ = false;
               break;
            case this.AC:
               this.cfQueuedVal = 0;
               this.cfQueuedOp = "";
            case this.CLX:
               this.cfDisplay = "";
               this.cfDispVal = 0;
               break;
            case this.COS:
               if(this.degMode == this.DEGREES_MODE)
               {
                  this.cfDispVal = GWizUtils.radians(this.cfDispVal);
               }
               this.cfDispVal = Math.cos(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.DEG:
               this.cfDispVal = GWizUtils.degrees(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               this.degMode = this.DEGREES_MODE;
               break;
            case this.I:
               this.cfDispVal = GWizUtils.inchToMM(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.INV:
               this.cfDispVal = 1 / this.cfDispVal;
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.LN:
               this.cfDispVal = Math.log(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.M:
               this.cfDispVal = GWizUtils.mmToInch(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.NEG:
               this.cfDispVal = -this.cfDispVal;
               this.cfDisplay = String(this.cfDispVal);
               _loc3_ = false;
               break;
            case this.PCT:
               this.cfDispVal /= 100;
               if(this.cfQueuedVal != 0)
               {
                  this.cfDispVal = this.cfQueuedVal * this.cfDispVal;
               }
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.PI:
               this.cfDispVal = Math.PI;
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.E:
               this.cfDispVal = Math.E;
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.RAD:
               this.cfDispVal = GWizUtils.radians(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               this.degMode = this.RADIANS_MODE;
               break;
            case this.SIN:
               if(this.degMode == this.DEGREES_MODE)
               {
                  this.cfDispVal = GWizUtils.radians(this.cfDispVal);
               }
               this.cfDispVal = Math.sin(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.SQR:
               this.cfDispVal *= this.cfDispVal;
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.SQRT:
               this.cfDispVal = Math.sqrt(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.TAN:
               if(this.degMode == this.DEGREES_MODE)
               {
                  this.cfDispVal = GWizUtils.radians(this.cfDispVal);
               }
               this.cfDispVal = Math.tan(this.cfDispVal);
               this.cfDisplay = String(this.cfDispVal);
               break;
            case this.TENTHS:
               this.cfDisplay = _loc2_.formatRoundingWithPrecision(this.cfDisplay,NumberBaseRoundType.NEAREST,4);
               this.cfDispVal = Number(this.cfDisplay);
               break;
            case this.THOUS:
               this.cfDisplay = String(GWizUtils.roundThousandths(Number(this.cfDisplay)));
               this.cfDispVal = Number(this.cfDisplay);
               break;
            default:
               GWizUtils.assert(false);
         }
         if(_loc3_)
         {
            this.cfQueuedOp = "=";
         }
      }
      
      private function _GWizCalculator_VerticalLayout1_c() : VerticalLayout
      {
         var _loc1_:VerticalLayout = new VerticalLayout();
         _loc1_.horizontalAlign = "center";
         return _loc1_;
      }
      
      private function _GWizCalculator_Array1_c() : Array
      {
         return [this._GWizCalculator_Group1_c(),this._GWizCalculator_HGroup2_c()];
      }
      
      private function _GWizCalculator_Group1_c() : Group
      {
         var _loc1_:Group = new Group();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Rect1_c(),this._GWizCalculator_HGroup1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.fill = this._GWizCalculator_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCalculator_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 2236962;
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingBottom = 4;
         _loc1_.paddingTop = 4;
         _loc1_.styleName = "calcTitleBar";
         _loc1_.mxmlContent = [this._GWizCalculator_Label1_c(),this._GWizCalculator_Spacer1_c(),this._GWizCalculator_Button1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "GWizard Calculator";
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.height = 18;
         _loc1_.width = 18;
         _loc1_.setStyle("cornerRadius",15);
         _loc1_.addEventListener("click",this.__detachBtn_click);
         _loc1_.id = "detachBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.detachBtn = _loc1_;
         BindingManager.executeBindings(this,"detachBtn",this.detachBtn);
         return _loc1_;
      }
      
      public function __detachBtn_click(param1:MouseEvent) : void
      {
         this.tearOffCalc();
      }
      
      private function _GWizCalculator_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.gap = 0;
         _loc1_.paddingBottom = 8;
         _loc1_.paddingLeft = 8;
         _loc1_.paddingRight = 8;
         _loc1_.paddingTop = 0;
         _loc1_.width = 270;
         _loc1_.mxmlContent = [this._GWizCalculator_VGroup1_c(),this._GWizCalculator_VGroup6_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.gap = 0;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizCalculator_HGroup3_c(),this._GWizCalculator_Spacer2_c(),this._GWizCalculator_Line1_c(),this._GWizCalculator_Spacer3_c(),this._GWizCalculator_HGroup5_c(),this._GWizCalculator_Spacer4_c(),this._GWizCalculator_Line2_c(),this._GWizCalculator_Spacer5_c(),this._GWizCalculator_ButtonBar1_i(),this._GWizCalculator_Spacer6_c(),this._GWizCalculator_ViewStack1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_HGroup4_c(),this._GWizCalculator_GWizFracChooser1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizCalculator_TextInput1_i(),this._GWizCalculator_Label2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.styleName = "calcTextEdit";
         _loc1_.selectable = true;
         _loc1_.editable = false;
         _loc1_.setStyle("focusAlpha",0);
         _loc1_.addEventListener("keyDown",this.__CalcDisplay_keyDown);
         _loc1_.addEventListener("valueCommit",this.__CalcDisplay_valueCommit);
         _loc1_.id = "CalcDisplay";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CalcDisplay = _loc1_;
         BindingManager.executeBindings(this,"CalcDisplay",this.CalcDisplay);
         return _loc1_;
      }
      
      public function __CalcDisplay_keyDown(param1:KeyboardEvent) : void
      {
         this.onKeyDown(param1);
      }
      
      public function __CalcDisplay_valueCommit(param1:FlexEvent) : void
      {
         this.valueChanged(param1);
      }
      
      private function _GWizCalculator_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "CalcOpDisplay";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CalcOpDisplay = _loc1_;
         BindingManager.executeBindings(this,"CalcOpDisplay",this.CalcOpDisplay);
         return _loc1_;
      }
      
      private function _GWizCalculator_GWizFracChooser1_i() : GWizFracChooser
      {
         var _loc1_:GWizFracChooser = new GWizFracChooser();
         _loc1_.id = "fracBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.fracBtn = _loc1_;
         BindingManager.executeBindings(this,"fracBtn",this.fracBtn);
         return _loc1_;
      }
      
      private function _GWizCalculator_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Line1_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentWidth = 100;
         _loc1_.stroke = this._GWizCalculator_SolidColorStroke1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCalculator_SolidColorStroke1_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 0;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizCalculator_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup5_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_VGroup2_c(),this._GWizCalculator_VGroup3_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 70;
         _loc1_.mxmlContent = [this._GWizCalculator_HGroup6_c(),this._GWizCalculator_HGroup7_c(),this._GWizCalculator_HGroup8_c(),this._GWizCalculator_HGroup9_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup6_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button2_c(),this._GWizCalculator_Button3_c(),this._GWizCalculator_Button4_c(),this._GWizCalculator_Button5_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button2_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "7";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button2_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button2_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("7");
      }
      
      private function _GWizCalculator_Button3_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "8";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button3_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button3_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("8");
      }
      
      private function _GWizCalculator_Button4_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "9";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button4_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button4_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("9");
      }
      
      private function _GWizCalculator_Button5_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "x";
         _loc1_.height = 35;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button5_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button5_click(param1:MouseEvent) : void
      {
         this.cfMultiplyBtn();
      }
      
      private function _GWizCalculator_HGroup7_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button6_c(),this._GWizCalculator_Button7_c(),this._GWizCalculator_Button8_c(),this._GWizCalculator_Button9_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button6_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "4";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button6_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button6_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("4");
      }
      
      private function _GWizCalculator_Button7_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "5";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button7_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button7_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("5");
      }
      
      private function _GWizCalculator_Button8_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "6";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button8_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button8_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("6");
      }
      
      private function _GWizCalculator_Button9_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "÷";
         _loc1_.height = 35;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button9_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button9_click(param1:MouseEvent) : void
      {
         this.cfDivideBtn();
      }
      
      private function _GWizCalculator_HGroup8_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button10_c(),this._GWizCalculator_Button11_c(),this._GWizCalculator_Button12_c(),this._GWizCalculator_Button13_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button10_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "1";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button10_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button10_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("1");
      }
      
      private function _GWizCalculator_Button11_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "2";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button11_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button11_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("2");
      }
      
      private function _GWizCalculator_Button12_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "3";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button12_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button12_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("3");
      }
      
      private function _GWizCalculator_Button13_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "+";
         _loc1_.height = 35;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button13_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button13_click(param1:MouseEvent) : void
      {
         this.cfPlusBtn();
      }
      
      private function _GWizCalculator_HGroup9_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button14_c(),this._GWizCalculator_Button15_c(),this._GWizCalculator_Button16_c(),this._GWizCalculator_Button17_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button14_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "0";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button14_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button14_click(param1:MouseEvent) : void
      {
         this.cfAddDigit("0");
      }
      
      private function _GWizCalculator_Button15_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = ".";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button15_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button15_click(param1:MouseEvent) : void
      {
         this.cfDecimalBtn();
      }
      
      private function _GWizCalculator_Button16_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "±";
         _loc1_.height = 35;
         _loc1_.styleName = "calcNumButton";
         _loc1_.setStyle("fontSize",14);
         _loc1_.addEventListener("click",this.___GWizCalculator_Button16_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button16_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.NEG);
      }
      
      private function _GWizCalculator_Button17_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 25;
         _loc1_.label = "-";
         _loc1_.height = 35;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button17_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button17_click(param1:MouseEvent) : void
      {
         this.cfSubtractBtn();
      }
      
      private function _GWizCalculator_VGroup3_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 30;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button18_i(),this._GWizCalculator_Button19_c(),this._GWizCalculator_Button20_c(),this._GWizCalculator_Button21_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button18_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 100;
         _loc1_.height = 30;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button18_click);
         _loc1_.id = "_GWizCalculator_Button18";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCalculator_Button18 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCalculator_Button18",this._GWizCalculator_Button18);
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button18_click(param1:MouseEvent) : void
      {
         this.pressedClear();
      }
      
      private function _GWizCalculator_Button19_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 100;
         _loc1_.label = "Backsp";
         _loc1_.height = 30;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.setStyle("fontSize",10);
         _loc1_.addEventListener("click",this.___GWizCalculator_Button19_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button19_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.BKSP);
      }
      
      private function _GWizCalculator_Button20_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 100;
         _loc1_.label = "%";
         _loc1_.height = 30;
         _loc1_.styleName = "calcOperatorButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button20_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button20_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.PCT);
      }
      
      private function _GWizCalculator_Button21_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 100;
         _loc1_.label = "=";
         _loc1_.percentHeight = 100;
         _loc1_.styleName = "calcEqualButton";
         _loc1_.addEventListener("click",this.___GWizCalculator_Button21_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button21_click(param1:MouseEvent) : void
      {
         this.cfEqualsBtn();
      }
      
      private function _GWizCalculator_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Line2_c() : Line
      {
         var _loc1_:Line = new Line();
         _loc1_.percentWidth = 100;
         _loc1_.stroke = this._GWizCalculator_SolidColorStroke2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCalculator_SolidColorStroke2_c() : SolidColorStroke
      {
         var _loc1_:SolidColorStroke = new SolidColorStroke();
         _loc1_.color = 0;
         _loc1_.weight = 2;
         _loc1_.caps = "square";
         return _loc1_;
      }
      
      private function _GWizCalculator_Spacer5_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_ButtonBar1_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.percentHeight = 100;
         _loc1_.requireSelection = true;
         _loc1_.styleName = "calcCategoryButtons";
         _loc1_.id = "_GWizCalculator_ButtonBar1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCalculator_ButtonBar1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCalculator_ButtonBar1",this._GWizCalculator_ButtonBar1);
         return _loc1_;
      }
      
      private function _GWizCalculator_Spacer6_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_ViewStack1_i() : ViewStack
      {
         var temp:ViewStack = new ViewStack();
         temp.percentWidth = 100;
         temp.height = 135;
         temp.setStyle("borderVisible",true);
         temp.setStyle("borderAlpha",1);
         temp.setStyle("borderColor",3355443);
         temp.setStyle("borderStyle","none");
         temp.setStyle("backgroundColor",11579825);
         temp.setStyle("backgroundAlpha",0);
         temp.addEventListener("change",this.__featureStack_change);
         temp.id = "featureStack";
         if(!temp.document)
         {
            temp.document = this;
         }
         temp.mx_internal::_documentDescriptor = new UIComponentDescriptor({
            "type":ViewStack,
            "id":"featureStack",
            "events":{"change":"__featureStack_change"},
            "stylesFactory":function():void
            {
               this.borderVisible = true;
               this.borderAlpha = 1;
               this.borderColor = 3355443;
               this.borderStyle = "none";
               this.backgroundColor = 11579825;
               this.backgroundAlpha = 0;
            },
            "propertiesFactory":function():Object
            {
               return {"childDescriptors":[new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Convert",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Convert",
                        "percentWidth":100,
                        "percentHeight":100,
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCalculator_Array15_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Angles",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"D:M:S",
                        "percentWidth":100,
                        "percentHeight":100,
                        "styleName":"calcCategoryPanel",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCalculator_Array19_c)
                     };
                  }
               }),new UIComponentDescriptor({
                  "type":NavigatorContent,
                  "id":"Trig",
                  "propertiesFactory":function():Object
                  {
                     return {
                        "label":"Trig",
                        "percentWidth":100,
                        "percentHeight":100,
                        "styleName":"calcCategoryPanel",
                        "mxmlContentFactory":new DeferredInstanceFromFunction(_GWizCalculator_Array20_c)
                     };
                  }
               })]};
            }
         });
         temp.mx_internal::_documentDescriptor.document = this;
         this.featureStack = temp;
         BindingManager.executeBindings(this,"featureStack",this.featureStack);
         return temp;
      }
      
      public function __featureStack_change(param1:IndexChangedEvent) : void
      {
         this.restoreFocus();
      }
      
      private function _GWizCalculator_Array15_c() : Array
      {
         return [this._GWizCalculator_VGroup4_c()];
      }
      
      private function _GWizCalculator_VGroup4_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizCalculator_HGroup10_c(),this._GWizCalculator_Spacer7_c(),this._GWizCalculator_HGroup11_c()];
         _loc1_.setStyle("fontSize",10);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup10_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_GWizUnitChooser1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_GWizUnitChooser1_i() : GWizUnitChooser
      {
         var _loc1_:GWizUnitChooser = new GWizUnitChooser();
         _loc1_.percentWidth = 100;
         _loc1_.paddingLeft = 10;
         _loc1_.paddingRight = 10;
         _loc1_.setStyle("color",15592941);
         _loc1_.id = "conversionPanel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.conversionPanel = _loc1_;
         BindingManager.executeBindings(this,"conversionPanel",this.conversionPanel);
         return _loc1_;
      }
      
      private function _GWizCalculator_Spacer7_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 10;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup11_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_TextInput2_i(),this._GWizCalculator_Button22_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.text = "0.0";
         _loc1_.enabled = false;
         _loc1_.id = "unitConvResult";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.unitConvResult = _loc1_;
         BindingManager.executeBindings(this,"unitConvResult",this.unitConvResult);
         return _loc1_;
      }
      
      private function _GWizCalculator_Button22_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Use";
         _loc1_.width = 70;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button22_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button22_click(param1:MouseEvent) : void
      {
         this.doUseValue();
      }
      
      private function _GWizCalculator_Array19_c() : Array
      {
         return [this._GWizCalculator_GWizAngleChooser1_i()];
      }
      
      private function _GWizCalculator_GWizAngleChooser1_i() : GWizAngleChooser
      {
         var _loc1_:GWizAngleChooser = new GWizAngleChooser();
         _loc1_.percentWidth = 100;
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.paddingTop = 5;
         _loc1_.setStyle("color",2236962);
         _loc1_.id = "_GWizCalculator_GWizAngleChooser1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCalculator_GWizAngleChooser1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCalculator_GWizAngleChooser1",this._GWizCalculator_GWizAngleChooser1);
         return _loc1_;
      }
      
      private function _GWizCalculator_Array20_c() : Array
      {
         return [this._GWizCalculator_VGroup5_c()];
      }
      
      private function _GWizCalculator_VGroup5_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.paddingTop = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizCalculator_HGroup12_c(),this._GWizCalculator_HGroup13_c(),this._GWizCalculator_HGroup14_c(),this._GWizCalculator_HGroup15_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_HGroup12_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button23_c(),this._GWizCalculator_Button24_c(),this._GWizCalculator_Button25_c(),this._GWizCalculator_Button26_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button23_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "sin";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button23_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button23_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.SIN);
      }
      
      private function _GWizCalculator_Button24_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "cos";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button24_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button24_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.COS);
      }
      
      private function _GWizCalculator_Button25_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "tan";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button25_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button25_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.TAN);
      }
      
      private function _GWizCalculator_Button26_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 34;
         _loc1_.label = "Tenths";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button26_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button26_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.TENTHS);
      }
      
      private function _GWizCalculator_HGroup13_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button27_c(),this._GWizCalculator_Button28_c(),this._GWizCalculator_Button29_c(),this._GWizCalculator_Button30_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button27_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "asin";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button27_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button27_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.ASIN);
      }
      
      private function _GWizCalculator_Button28_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "acos";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button28_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button28_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.ACOS);
      }
      
      private function _GWizCalculator_Button29_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "atan";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button29_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button29_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.ATAN);
      }
      
      private function _GWizCalculator_Button30_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 34;
         _loc1_.label = "Thous";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button30_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button30_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.THOUS);
      }
      
      private function _GWizCalculator_HGroup14_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button31_c(),this._GWizCalculator_Button32_c(),this._GWizCalculator_Button33_c(),this._GWizCalculator_Button34_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button31_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "X^Y";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button31_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button31_click(param1:MouseEvent) : void
      {
         this.cfXtoYBtn();
      }
      
      private function _GWizCalculator_Button32_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "X^2";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button32_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button32_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.SQR);
      }
      
      private function _GWizCalculator_Button33_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "sqrt";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button33_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button33_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.SQRT);
      }
      
      private function _GWizCalculator_Button34_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 34;
         _loc1_.label = "ln";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button34_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button34_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.LN);
      }
      
      private function _GWizCalculator_HGroup15_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCalculator_Button35_c(),this._GWizCalculator_Button36_c(),this._GWizCalculator_Button37_c(),this._GWizCalculator_ButtonBar2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Button35_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "1/x";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.addEventListener("click",this.___GWizCalculator_Button35_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button35_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.INV);
      }
      
      private function _GWizCalculator_Button36_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "Pi";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("fontStyle","normal");
         _loc1_.addEventListener("click",this.___GWizCalculator_Button36_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button36_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.PI);
      }
      
      private function _GWizCalculator_Button37_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.percentWidth = 22;
         _loc1_.label = "e";
         _loc1_.styleName = "calcFnButton";
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("fontStyle","normal");
         _loc1_.addEventListener("click",this.___GWizCalculator_Button37_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizCalculator_Button37_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(this.E);
      }
      
      private function _GWizCalculator_ButtonBar2_i() : ButtonBar
      {
         var _loc1_:ButtonBar = new ButtonBar();
         _loc1_.percentWidth = 34;
         _loc1_.styleName = "radDegToggleButtonBar";
         _loc1_.selectedIndex = 0;
         _loc1_.addEventListener("click",this.___GWizCalculator_ButtonBar2_click);
         _loc1_.id = "_GWizCalculator_ButtonBar2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizCalculator_ButtonBar2 = _loc1_;
         BindingManager.executeBindings(this,"_GWizCalculator_ButtonBar2",this._GWizCalculator_ButtonBar2);
         return _loc1_;
      }
      
      public function ___GWizCalculator_ButtonBar2_click(param1:MouseEvent) : void
      {
         this.cfPostfixOp(param1.currentTarget.selectedItem);
      }
      
      private function _GWizCalculator_VGroup6_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.width = 0;
         _loc1_.mxmlContent = [this._GWizCalculator_Label3_i(),this._GWizCalculator_Label4_i(),this._GWizCalculator_Label5_i(),this._GWizCalculator_Label6_i(),this._GWizCalculator_Label7_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCalculator_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.visible = false;
         _loc1_.id = "c1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.c1 = _loc1_;
         BindingManager.executeBindings(this,"c1",this.c1);
         return _loc1_;
      }
      
      private function _GWizCalculator_Label4_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "1.0";
         _loc1_.visible = false;
         _loc1_.id = "m1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.m1 = _loc1_;
         BindingManager.executeBindings(this,"m1",this.m1);
         return _loc1_;
      }
      
      private function _GWizCalculator_Label5_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "0.0";
         _loc1_.visible = false;
         _loc1_.id = "c2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.c2 = _loc1_;
         BindingManager.executeBindings(this,"c2",this.c2);
         return _loc1_;
      }
      
      private function _GWizCalculator_Label6_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "1.0";
         _loc1_.visible = false;
         _loc1_.id = "m2";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.m2 = _loc1_;
         BindingManager.executeBindings(this,"m2",this.m2);
         return _loc1_;
      }
      
      private function _GWizCalculator_Label7_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Length";
         _loc1_.visible = false;
         _loc1_.id = "unitType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.unitType = _loc1_;
         BindingManager.executeBindings(this,"unitType",this.unitType);
         return _loc1_;
      }
      
      public function ___GWizCalculator_GWizPanel1_creationComplete(param1:FlexEvent) : void
      {
         this.restoreFocus();
      }
      
      public function ___GWizCalculator_GWizPanel1_show(param1:FlexEvent) : void
      {
         this.restoreFocus();
      }
      
      private function _GWizCalculator_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():*
         {
            return CalcDisplay.text;
         },function(param1:*):void
         {
            cfDisplay = param1;
         },"cfDisplay");
         result[1] = new Binding(this,null,function(param1:*):void
         {
            CalcDisplay.text = param1;
         },"CalcDisplay.text","cfDisplay");
         result[1].twoWayCounterpart = result[0];
         result[0].twoWayCounterpart = result[1];
         result[2] = new Binding(this,null,function(param1:Object):void
         {
            detachBtn.setStyle("icon",param1);
         },"detachBtn.icon","detachImg");
         result[3] = new Binding(this,function():String
         {
            var _loc1_:* = cfQueuedOp;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"CalcOpDisplay.text");
         result[4] = new Binding(this,null,null,"fracBtn.textInpRef","CalcDisplay");
         result[5] = new Binding(this,function():String
         {
            var _loc1_:* = clearLabel;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizCalculator_Button18.label");
         result[6] = new Binding(this,null,null,"_GWizCalculator_ButtonBar1.dataProvider","featureStack");
         result[7] = new Binding(this,null,null,"conversionPanel.c1Ref","c1");
         result[8] = new Binding(this,null,null,"conversionPanel.c2Ref","c2");
         result[9] = new Binding(this,null,null,"conversionPanel.m1Ref","m1");
         result[10] = new Binding(this,null,null,"conversionPanel.m2Ref","m2");
         result[11] = new Binding(this,function():Function
         {
            return this.showUnits;
         },null,"conversionPanel.doConversion");
         result[12] = new Binding(this,null,null,"_GWizCalculator_GWizAngleChooser1.textInpRef","CalcDisplay");
         result[13] = new Binding(this,function():IList
         {
            return radDegLabels;
         },null,"_GWizCalculator_ButtonBar2.dataProvider");
         return result;
      }
      
      private function _GWizCalculator_bindingExprs() : void
      {
         var _loc1_:* = undefined;
         this.cfDisplay = this.CalcDisplay.text;
         this.CalcDisplay.text = this.cfDisplay;
      }
      
      mx_internal function _GWizCalculator_StylesInit() : void
      {
         var style:CSSStyleDeclaration = null;
         var effects:Array = null;
         var conditions:Array = null;
         var condition:CSSCondition = null;
         var selector:CSSSelector = null;
         if(mx_internal::_GWizCalculator_StylesInit_done)
         {
            return;
         }
         mx_internal::_GWizCalculator_StylesInit_done = true;
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcNumButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcNumButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 734012;
               this.chromeColor = 13421772;
               this.fontSize = 18;
               this.fillAlphas = [1,1,1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcOperatorButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcOperatorButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 734012;
               this.chromeColor = "primary4";
               this.fontSize = 18;
               this.fillAlphas = [1,1,1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcEqualButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcEqualButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 734012;
               this.chromeColor = "complement4";
               this.fontSize = 18;
               this.fillAlphas = [1,1,1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcFnButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcFnButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.paddingTop = 0;
               this.color = 734012;
               this.fillColors = [9934743,9934743,39270,39270];
               this.fontSize = 10;
               this.fillAlphas = [1,1,1,1];
               this.paddingBottom = 0;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcCategoryButtons");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcCategoryButtons");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.buttonStyleName = "calcCategoryButton";
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcCategoryButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcCategoryButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.cornerRadius = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = null;
         selector = new CSSSelector("*",conditions,selector);
         style = styleManager.getStyleDeclaration("*");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.cornerRadius = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","geoTabBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".geoTabBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 15658734;
               this.backgroundColor = 0;
               this.chromeColor = 2904884;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","threadTabBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".threadTabBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 15658734;
               this.backgroundColor = "secondarya3";
               this.chromeColor = "secondarya4";
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcCategoryPanel");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcCategoryPanel");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 2236962;
               this.backgroundAlpha = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","geoView");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".geoView");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.backgroundColor = 15398372;
               this.backgroundAlpha = 1;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcTextEdit");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcTextEdit");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.borderStyle = "none";
               this.fontSize = 12;
               this.disabledColor = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","resistorBand");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".resistorBand");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fillColors = [16255241,16255241];
               this.fillAlphas = [1,1];
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","calcTitleBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".calcTitleBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.contentBackgroundAlpha = 1;
               this.color = 15658734;
               this.chromeColor = 8947848;
               this.contentBackgroundColor = 8947848;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","detachButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".detachButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.skin = ProgrammaticSkin;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegToggleButtonBar");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegToggleButtonBar");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1184274;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegFirstToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegFirstToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1184274;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegLastToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegLastToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1184274;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","radDegSelectedToggleButton");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".radDegSelectedToggleButton");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.color = 1118549;
               this.fontSize = 7;
               this.paddingLeft = 0;
               this.paddingRight = 0;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","customAccordionHead");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".customAccordionHead");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontWeight = "bold";
               this.color = "primary3";
               this.textRollOverColor = 16777215;
               this.fontSize = 12;
               this.textSelectedColor = "complement5";
               this.skin = GWizAccordionHeaderSkin;
            };
         }
         selector = null;
         conditions = null;
         conditions = [];
         condition = new CSSCondition("class","tabHeader");
         conditions.push(condition);
         selector = new CSSSelector("",conditions,selector);
         style = styleManager.getStyleDeclaration(".tabHeader");
         if(!style)
         {
            style = new CSSStyleDeclaration(selector,styleManager);
         }
         if(style.factory == null)
         {
            style.factory = function():void
            {
               this.fontWeight = "normal";
               this.fontSizeDelta = -2;
               this.fillAlphas = [0.6,0.7,0.75,0.65];
            };
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Angles() : NavigatorContent
      {
         return this._1965657632Angles;
      }
      
      public function set Angles(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1965657632Angles;
         if(_loc2_ !== param1)
         {
            this._1965657632Angles = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Angles",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CalcDisplay() : TextInput
      {
         return this._125797517CalcDisplay;
      }
      
      public function set CalcDisplay(param1:TextInput) : void
      {
         var _loc2_:Object = this._125797517CalcDisplay;
         if(_loc2_ !== param1)
         {
            this._125797517CalcDisplay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CalcDisplay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get CalcOpDisplay() : Label
      {
         return this._1711531860CalcOpDisplay;
      }
      
      public function set CalcOpDisplay(param1:Label) : void
      {
         var _loc2_:Object = this._1711531860CalcOpDisplay;
         if(_loc2_ !== param1)
         {
            this._1711531860CalcOpDisplay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CalcOpDisplay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Convert() : NavigatorContent
      {
         return this._1678723693Convert;
      }
      
      public function set Convert(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._1678723693Convert;
         if(_loc2_ !== param1)
         {
            this._1678723693Convert = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Convert",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Trig() : NavigatorContent
      {
         return this._2615356Trig;
      }
      
      public function set Trig(param1:NavigatorContent) : void
      {
         var _loc2_:Object = this._2615356Trig;
         if(_loc2_ !== param1)
         {
            this._2615356Trig = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Trig",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get c1() : Label
      {
         return this._3118c1;
      }
      
      public function set c1(param1:Label) : void
      {
         var _loc2_:Object = this._3118c1;
         if(_loc2_ !== param1)
         {
            this._3118c1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"c1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get c2() : Label
      {
         return this._3119c2;
      }
      
      public function set c2(param1:Label) : void
      {
         var _loc2_:Object = this._3119c2;
         if(_loc2_ !== param1)
         {
            this._3119c2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"c2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get conversionPanel() : GWizUnitChooser
      {
         return this._609849998conversionPanel;
      }
      
      public function set conversionPanel(param1:GWizUnitChooser) : void
      {
         var _loc2_:Object = this._609849998conversionPanel;
         if(_loc2_ !== param1)
         {
            this._609849998conversionPanel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"conversionPanel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get detachBtn() : Button
      {
         return this._1978768951detachBtn;
      }
      
      public function set detachBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1978768951detachBtn;
         if(_loc2_ !== param1)
         {
            this._1978768951detachBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"detachBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get featureStack() : ViewStack
      {
         return this._1198113074featureStack;
      }
      
      public function set featureStack(param1:ViewStack) : void
      {
         var _loc2_:Object = this._1198113074featureStack;
         if(_loc2_ !== param1)
         {
            this._1198113074featureStack = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"featureStack",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fracBtn() : GWizFracChooser
      {
         return this._607583858fracBtn;
      }
      
      public function set fracBtn(param1:GWizFracChooser) : void
      {
         var _loc2_:Object = this._607583858fracBtn;
         if(_loc2_ !== param1)
         {
            this._607583858fracBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fracBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get m1() : Label
      {
         return this._3428m1;
      }
      
      public function set m1(param1:Label) : void
      {
         var _loc2_:Object = this._3428m1;
         if(_loc2_ !== param1)
         {
            this._3428m1 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"m1",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get m2() : Label
      {
         return this._3429m2;
      }
      
      public function set m2(param1:Label) : void
      {
         var _loc2_:Object = this._3429m2;
         if(_loc2_ !== param1)
         {
            this._3429m2 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"m2",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get unitConvResult() : TextInput
      {
         return this._631229717unitConvResult;
      }
      
      public function set unitConvResult(param1:TextInput) : void
      {
         var _loc2_:Object = this._631229717unitConvResult;
         if(_loc2_ !== param1)
         {
            this._631229717unitConvResult = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitConvResult",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get unitType() : Label
      {
         return this._292652322unitType;
      }
      
      public function set unitType(param1:Label) : void
      {
         var _loc2_:Object = this._292652322unitType;
         if(_loc2_ !== param1)
         {
            this._292652322unitType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"unitType",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get attachImg() : Class
      {
         return this._479015106attachImg;
      }
      
      public function set attachImg(param1:Class) : void
      {
         var _loc2_:Object = this._479015106attachImg;
         if(_loc2_ !== param1)
         {
            this._479015106attachImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"attachImg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get detachImg() : Class
      {
         return this._1978762448detachImg;
      }
      
      public function set detachImg(param1:Class) : void
      {
         var _loc2_:Object = this._1978762448detachImg;
         if(_loc2_ !== param1)
         {
            this._1978762448detachImg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"detachImg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get cfQueuedOp() : String
      {
         return this._1243406391cfQueuedOp;
      }
      
      private function set cfQueuedOp(param1:String) : void
      {
         var _loc2_:Object = this._1243406391cfQueuedOp;
         if(_loc2_ !== param1)
         {
            this._1243406391cfQueuedOp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cfQueuedOp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function set cfDisplay(param1:String) : void
      {
         var _loc2_:Object = this.cfDisplay;
         if(_loc2_ !== param1)
         {
            this._2129887521cfDisplay = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cfDisplay",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get clearLabel() : String
      {
         return this._750927705clearLabel;
      }
      
      private function set clearLabel(param1:String) : void
      {
         var _loc2_:Object = this._750927705clearLabel;
         if(_loc2_ !== param1)
         {
            this._750927705clearLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"clearLabel",_loc2_,param1));
            }
         }
      }
   }
}
