package comps
{
   import configinfo.GWizSettings;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
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
   import spark.components.BorderContainer;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.NumericStepper;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.formatters.DateTimeFormatter;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizToDo extends BorderContainer implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizToDo_Button1:Button;
      
      public var _GWizToDo_Button3:Button;
      
      public var _GWizToDo_Button5:Button;
      
      private var _713103008bigGoals:TextArea;
      
      private var _1378833175btnGrp:HGroup;
      
      private var _957830652counter:Label;
      
      private var _779770692dateFormatter:DateTimeFormatter;
      
      private var _2074415255longTime:NumericStepper;
      
      private var _1273664646pauseBtn:Button;
      
      private var _732084871shortBreakBtn:Button;
      
      private var _2028032663shortTime:NumericStepper;
      
      private var _706048496slackGoals:TextArea;
      
      private var _34839934workTime:NumericStepper;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private const BIG_GOALS:String = "BigGoals.txt";
      
      private const SLACK_GOALS:String = "SlackGoals.txt";
      
      private var _2013291755activeModeHighlight:uint = 16777215;
      
      private var _709309350inactiveModeHighlight:uint = 16777215;
      
      private const TIMER_INTERVAL:int = 10;
      
      private var baseTimer:int;
      
      private var t:Timer;
      
      public var timerEnded:Function;
      
      private var paused:Boolean = false;
      
      private var timeLeft:Number;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizToDo()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizToDo_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizToDoWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizToDo[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizToDo_Array1_c);
         this._GWizToDo_DateTimeFormatter1_i();
         this.addEventListener("creationComplete",this.___GWizToDo_BorderContainer1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizToDo._watcherSetupUtil = param1;
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
         var file:File = null;
         var stream:FileStream = null;
         var buffer:String = null;
         this.initTimer();
         try
         {
            file = GWizSettings.getPrefsFile(this.BIG_GOALS);
            stream = new FileStream();
            if(file.exists)
            {
               stream.open(file,FileMode.READ);
               buffer = stream.readUTFBytes(stream.bytesAvailable);
               this.bigGoals.text = buffer;
            }
            else
            {
               this.bigGoals.text = "Enter your big goals for the day here.";
            }
            stream.close();
            file = GWizSettings.getPrefsFile(this.SLACK_GOALS);
            stream = new FileStream();
            if(file.exists)
            {
               stream.open(file,FileMode.READ);
               buffer = stream.readUTFBytes(stream.bytesAvailable);
               this.slackGoals.text = buffer;
            }
            else
            {
               this.slackGoals.text = "Enter your slack time goals here.";
            }
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error loading goals.txt. msg = " + e.message);
            GWizUtils.assert(false);
         }
      }
      
      public function saveGoals() : void
      {
         var file:File = null;
         var stream:FileStream = null;
         try
         {
            file = GWizSettings.getPrefsFile(this.BIG_GOALS);
            stream = new FileStream();
            stream.open(file,FileMode.WRITE);
            stream.writeUTFBytes(this.bigGoals.text);
            stream.close();
            file = GWizSettings.getPrefsFile(this.SLACK_GOALS);
            stream = new FileStream();
            stream.open(file,FileMode.WRITE);
            stream.writeUTFBytes(this.slackGoals.text);
            stream.close();
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Error saving goals.txt. msg = " + e.message);
            GWizUtils.assert(false);
         }
      }
      
      private function initTimer() : void
      {
         this.t = new Timer(this.TIMER_INTERVAL);
         this.t.addEventListener(TimerEvent.TIMER,this.updateTimer);
      }
      
      private function updateTimer(param1:TimerEvent) : void
      {
         var _loc2_:Date = new Date(this.baseTimer - getTimer());
         this.counter.text = this.dateFormatter.format(_loc2_);
         if(getTimer() > this.baseTimer)
         {
            this.stopTimer();
            this.counter.text = "00:00";
            if(this.timerEnded != null)
            {
               this.timerEnded();
            }
            GWizPopUpManager.Show("Period ended.  Time to try something else?","Coming Soon!",GWizPopUpManager.WARN);
         }
      }
      
      private function startTimer(param1:String) : void
      {
         var _loc2_:Number = 0;
         switch(param1)
         {
            case "WORK":
               _loc2_ = this.workTime.value;
               this.slackGoals.setStyle("color",ColorPalette.gray4);
               this.bigGoals.setStyle("color",0);
               this.bigGoals.setStyle("contentBackgroundColor",this.activeModeHighlight);
               this.slackGoals.setStyle("contentBackgroundColor",this.inactiveModeHighlight);
               break;
            case "SHORT":
               _loc2_ = this.shortTime.value;
               this.bigGoals.setStyle("color",ColorPalette.gray4);
               this.slackGoals.setStyle("color",0);
               this.bigGoals.setStyle("contentBackgroundColor",this.inactiveModeHighlight);
               this.slackGoals.setStyle("contentBackgroundColor",this.activeModeHighlight);
               break;
            case "LONG":
               _loc2_ = this.longTime.value;
               this.bigGoals.setStyle("color",ColorPalette.gray4);
               this.slackGoals.setStyle("color",0);
               this.bigGoals.setStyle("contentBackgroundColor",this.inactiveModeHighlight);
               this.slackGoals.setStyle("contentBackgroundColor",this.activeModeHighlight);
               break;
            default:
               _loc2_ = this.timeLeft / (60 * 1000);
         }
         this.baseTimer = getTimer() + _loc2_ * 60 * 1000;
         this.t.start();
      }
      
      private function stopTimer() : void
      {
         this.t.stop();
         this.bigGoals.setStyle("color",0);
         this.slackGoals.setStyle("color",0);
         this.bigGoals.setStyle("contentBackgroundColor",this.inactiveModeHighlight);
         this.slackGoals.setStyle("contentBackgroundColor",this.inactiveModeHighlight);
      }
      
      private function pauseTimer() : void
      {
         if(this.counter.text == "00:00")
         {
            return;
         }
         this.paused = !this.paused;
         if(this.paused)
         {
            this.stopTimer();
            this.timeLeft = this.baseTimer - getTimer();
            this.pauseBtn.label = "Restart";
         }
         else
         {
            this.startTimer("RESTART");
            this.pauseBtn.label = "Pause";
         }
      }
      
      private function doWorkSmarter() : void
      {
         GWizUtils.doWebPage("http://bobwarfield.com/work-smarter-get-things-done/");
      }
      
      private function _GWizToDo_DateTimeFormatter1_i() : DateTimeFormatter
      {
         var _loc1_:DateTimeFormatter = new DateTimeFormatter();
         _loc1_.dateTimePattern = "mm:ss";
         _loc1_.initialized(this,"dateFormatter");
         this.dateFormatter = _loc1_;
         BindingManager.executeBindings(this,"dateFormatter",this.dateFormatter);
         return _loc1_;
      }
      
      private function _GWizToDo_Array1_c() : Array
      {
         return [this._GWizToDo_GWizForePanel1_c()];
      }
      
      private function _GWizToDo_GWizForePanel1_c() : GWizForePanel
      {
         var _loc1_:GWizForePanel = new GWizForePanel();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizToDo_Array2_c);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_Array2_c() : Array
      {
         return [this._GWizToDo_VGroup1_c()];
      }
      
      private function _GWizToDo_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.paddingTop = 5;
         _loc1_.paddingBottom = 5;
         _loc1_.paddingLeft = 5;
         _loc1_.paddingRight = 5;
         _loc1_.mxmlContent = [this._GWizToDo_HGroup1_i(),this._GWizToDo_Label1_c(),this._GWizToDo_Label2_i(),this._GWizToDo_Label3_c(),this._GWizToDo_Label4_c(),this._GWizToDo_TextArea1_i(),this._GWizToDo_Label5_c(),this._GWizToDo_TextArea2_i(),this._GWizToDo_HGroup2_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_HGroup1_i() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizToDo_Button1_i(),this._GWizToDo_Button2_i(),this._GWizToDo_Button3_i(),this._GWizToDo_Button4_i(),this._GWizToDo_Button5_i(),this._GWizToDo_Spacer1_c(),this._GWizToDo_Button6_c()];
         _loc1_.id = "btnGrp";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.btnGrp = _loc1_;
         BindingManager.executeBindings(this,"btnGrp",this.btnGrp);
         return _loc1_;
      }
      
      private function _GWizToDo_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Work";
         _loc1_.addEventListener("click",this.___GWizToDo_Button1_click);
         _loc1_.id = "_GWizToDo_Button1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToDo_Button1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToDo_Button1",this._GWizToDo_Button1);
         return _loc1_;
      }
      
      public function ___GWizToDo_Button1_click(param1:MouseEvent) : void
      {
         this.startTimer("WORK");
      }
      
      private function _GWizToDo_Button2_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Short Break";
         _loc1_.addEventListener("click",this.__shortBreakBtn_click);
         _loc1_.id = "shortBreakBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.shortBreakBtn = _loc1_;
         BindingManager.executeBindings(this,"shortBreakBtn",this.shortBreakBtn);
         return _loc1_;
      }
      
      public function __shortBreakBtn_click(param1:MouseEvent) : void
      {
         this.startTimer("SHORT");
      }
      
      private function _GWizToDo_Button3_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Long Break";
         _loc1_.addEventListener("click",this.___GWizToDo_Button3_click);
         _loc1_.id = "_GWizToDo_Button3";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToDo_Button3 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToDo_Button3",this._GWizToDo_Button3);
         return _loc1_;
      }
      
      public function ___GWizToDo_Button3_click(param1:MouseEvent) : void
      {
         this.startTimer("LONG");
      }
      
      private function _GWizToDo_Button4_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Pause";
         _loc1_.addEventListener("click",this.__pauseBtn_click);
         _loc1_.id = "pauseBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.pauseBtn = _loc1_;
         BindingManager.executeBindings(this,"pauseBtn",this.pauseBtn);
         return _loc1_;
      }
      
      public function __pauseBtn_click(param1:MouseEvent) : void
      {
         this.pauseTimer();
      }
      
      private function _GWizToDo_Button5_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Clear";
         _loc1_.addEventListener("click",this.___GWizToDo_Button5_click);
         _loc1_.id = "_GWizToDo_Button5";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizToDo_Button5 = _loc1_;
         BindingManager.executeBindings(this,"_GWizToDo_Button5",this._GWizToDo_Button5);
         return _loc1_;
      }
      
      public function ___GWizToDo_Button5_click(param1:MouseEvent) : void
      {
         this.stopTimer();
         this.counter.text = "00:00";
      }
      
      private function _GWizToDo_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_Button6_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Free Work Smarter Course";
         _loc1_.toolTip = "Get our free online productivity course and learn to use the ToDo Wizard.";
         _loc1_.addEventListener("click",this.___GWizToDo_Button6_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizToDo_Button6_click(param1:MouseEvent) : void
      {
         this.doWorkSmarter();
      }
      
      private function _GWizToDo_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "00:00";
         _loc1_.setStyle("fontSize",36);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "counter";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.counter = _loc1_;
         BindingManager.executeBindings(this,"counter",this.counter);
         return _loc1_;
      }
      
      private function _GWizToDo_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "   ";
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Today\'s Big Goals";
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "bigGoals";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.bigGoals = _loc1_;
         BindingManager.executeBindings(this,"bigGoals",this.bigGoals);
         return _loc1_;
      }
      
      private function _GWizToDo_Label5_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Slack Work";
         _loc1_.setStyle("fontSize",16);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_TextArea2_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentHeight = 100;
         _loc1_.percentWidth = 100;
         _loc1_.setStyle("fontSize",14);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "slackGoals";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.slackGoals = _loc1_;
         BindingManager.executeBindings(this,"slackGoals",this.slackGoals);
         return _loc1_;
      }
      
      private function _GWizToDo_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizToDo_Label6_c(),this._GWizToDo_NumericStepper1_i(),this._GWizToDo_Label7_c(),this._GWizToDo_NumericStepper2_i(),this._GWizToDo_Label8_c(),this._GWizToDo_NumericStepper3_i(),this._GWizToDo_Spacer2_c(),this._GWizToDo_Button7_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_Label6_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Work (min):";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_NumericStepper1_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 60;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("change",this.__workTime_change);
         _loc1_.id = "workTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.workTime = _loc1_;
         BindingManager.executeBindings(this,"workTime",this.workTime);
         return _loc1_;
      }
      
      public function __workTime_change(param1:Event) : void
      {
         GWizSettings.workTime = this.workTime.value;
      }
      
      private function _GWizToDo_Label7_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Short Break (min):";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_NumericStepper2_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 60;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("change",this.__shortTime_change);
         _loc1_.id = "shortTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.shortTime = _loc1_;
         BindingManager.executeBindings(this,"shortTime",this.shortTime);
         return _loc1_;
      }
      
      public function __shortTime_change(param1:Event) : void
      {
         GWizSettings.shortTime = this.shortTime.value;
      }
      
      private function _GWizToDo_Label8_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Long Break (min):";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_NumericStepper3_i() : NumericStepper
      {
         var _loc1_:NumericStepper = new NumericStepper();
         _loc1_.minimum = 0;
         _loc1_.maximum = 60;
         _loc1_.stepSize = 1;
         _loc1_.addEventListener("change",this.__longTime_change);
         _loc1_.id = "longTime";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.longTime = _loc1_;
         BindingManager.executeBindings(this,"longTime",this.longTime);
         return _loc1_;
      }
      
      public function __longTime_change(param1:Event) : void
      {
         GWizSettings.longTime = this.longTime.value;
      }
      
      private function _GWizToDo_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizToDo_Button7_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Save";
         _loc1_.addEventListener("click",this.___GWizToDo_Button7_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizToDo_Button7_click(param1:MouseEvent) : void
      {
         this.saveGoals();
      }
      
      public function ___GWizToDo_BorderContainer1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizToDo_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return ColorPalette.gray4;
         },function(param1:uint):void
         {
            this.setStyle("backgroundColor",param1);
         },"this.backgroundColor");
         result[1] = new Binding(this,function():Number
         {
            return shortBreakBtn.width;
         },null,"_GWizToDo_Button1.width");
         result[2] = new Binding(this,function():Number
         {
            return shortBreakBtn.width;
         },null,"_GWizToDo_Button3.width");
         result[3] = new Binding(this,function():Number
         {
            return shortBreakBtn.width;
         },null,"pauseBtn.width");
         result[4] = new Binding(this,function():Number
         {
            return shortBreakBtn.width;
         },null,"_GWizToDo_Button5.width");
         result[5] = new Binding(this,function():Number
         {
            return GWizSettings.workTime;
         },null,"workTime.value");
         result[6] = new Binding(this,function():Number
         {
            return GWizSettings.shortTime;
         },null,"shortTime.value");
         result[7] = new Binding(this,function():Number
         {
            return GWizSettings.longTime;
         },null,"longTime.value");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get bigGoals() : TextArea
      {
         return this._713103008bigGoals;
      }
      
      public function set bigGoals(param1:TextArea) : void
      {
         var _loc2_:Object = this._713103008bigGoals;
         if(_loc2_ !== param1)
         {
            this._713103008bigGoals = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"bigGoals",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get btnGrp() : HGroup
      {
         return this._1378833175btnGrp;
      }
      
      public function set btnGrp(param1:HGroup) : void
      {
         var _loc2_:Object = this._1378833175btnGrp;
         if(_loc2_ !== param1)
         {
            this._1378833175btnGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"btnGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get counter() : Label
      {
         return this._957830652counter;
      }
      
      public function set counter(param1:Label) : void
      {
         var _loc2_:Object = this._957830652counter;
         if(_loc2_ !== param1)
         {
            this._957830652counter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"counter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get dateFormatter() : DateTimeFormatter
      {
         return this._779770692dateFormatter;
      }
      
      public function set dateFormatter(param1:DateTimeFormatter) : void
      {
         var _loc2_:Object = this._779770692dateFormatter;
         if(_loc2_ !== param1)
         {
            this._779770692dateFormatter = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"dateFormatter",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get longTime() : NumericStepper
      {
         return this._2074415255longTime;
      }
      
      public function set longTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._2074415255longTime;
         if(_loc2_ !== param1)
         {
            this._2074415255longTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"longTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get pauseBtn() : Button
      {
         return this._1273664646pauseBtn;
      }
      
      public function set pauseBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1273664646pauseBtn;
         if(_loc2_ !== param1)
         {
            this._1273664646pauseBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"pauseBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get shortBreakBtn() : Button
      {
         return this._732084871shortBreakBtn;
      }
      
      public function set shortBreakBtn(param1:Button) : void
      {
         var _loc2_:Object = this._732084871shortBreakBtn;
         if(_loc2_ !== param1)
         {
            this._732084871shortBreakBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shortBreakBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get shortTime() : NumericStepper
      {
         return this._2028032663shortTime;
      }
      
      public function set shortTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._2028032663shortTime;
         if(_loc2_ !== param1)
         {
            this._2028032663shortTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"shortTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get slackGoals() : TextArea
      {
         return this._706048496slackGoals;
      }
      
      public function set slackGoals(param1:TextArea) : void
      {
         var _loc2_:Object = this._706048496slackGoals;
         if(_loc2_ !== param1)
         {
            this._706048496slackGoals = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"slackGoals",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get workTime() : NumericStepper
      {
         return this._34839934workTime;
      }
      
      public function set workTime(param1:NumericStepper) : void
      {
         var _loc2_:Object = this._34839934workTime;
         if(_loc2_ !== param1)
         {
            this._34839934workTime = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"workTime",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get activeModeHighlight() : uint
      {
         return this._2013291755activeModeHighlight;
      }
      
      public function set activeModeHighlight(param1:uint) : void
      {
         var _loc2_:Object = this._2013291755activeModeHighlight;
         if(_loc2_ !== param1)
         {
            this._2013291755activeModeHighlight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"activeModeHighlight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get inactiveModeHighlight() : uint
      {
         return this._709309350inactiveModeHighlight;
      }
      
      public function set inactiveModeHighlight(param1:uint) : void
      {
         var _loc2_:Object = this._709309350inactiveModeHighlight;
         if(_loc2_ !== param1)
         {
            this._709309350inactiveModeHighlight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"inactiveModeHighlight",_loc2_,param1));
            }
         }
      }
   }
}
