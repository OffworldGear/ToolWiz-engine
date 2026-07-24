package comps
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.globalization.LocaleID;
   import flash.globalization.NumberFormatter;
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
   import spark.components.Button;
   import spark.components.CheckBox;
   import spark.components.Label;
   import spark.components.TextArea;
   import spark.components.VGroup;
   import spark.components.Window;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizDebugLogReader extends Window implements IBindingClient
   {
      
      public static var logWindow:GWizDebugLogReader = null;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1945385678infoBtn:Button;
      
      private var _1995593232logLabel:Label;
      
      private var _1974980347logToFile:CheckBox;
      
      private var _816631278viewer:TextArea;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDebugLogReader()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDebugLogReader_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizDebugLogReaderWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDebugLogReader[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Debug Log";
         this.width = 800;
         this.height = 600;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizDebugLogReader_Array1_c);
         this.addEventListener("creationComplete",this.___GWizDebugLogReader_Window1_creationComplete);
         this.addEventListener("close",this.___GWizDebugLogReader_Window1_close);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function newDebugLogReader() : void
      {
         logWindow = new GWizDebugLogReader();
         logWindow.open();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDebugLogReader._watcherSetupUtil = param1;
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
      
      private function initDebugOpts() : void
      {
      }
      
      private function doLogging(param1:Event = null) : void
      {
         GWizUtils.LogErrorToFile = this.logToFile.selected;
      }
      
      private function addInfo(param1:Event = null) : void
      {
         GWizUtils.LogError("******************** INFO BEGIN ***********************\n");
         GWizUtils.LogError("LocaleID = " + LocaleID.DEFAULT);
         var _loc2_:NumberFormatter = new NumberFormatter(LocaleID.DEFAULT);
         GWizUtils.LogError("actualLocaleIDName = " + _loc2_.actualLocaleIDName);
         GWizUtils.LogError("decimalSeparator = " + _loc2_.decimalSeparator);
         GWizUtils.LogError("digitsType = " + _loc2_.digitsType);
         GWizUtils.LogError("fractionalDigits = " + _loc2_.fractionalDigits);
         GWizUtils.LogError("groupingPattern = " + _loc2_.groupingPattern);
         GWizUtils.LogError("groupingSeparator = " + _loc2_.groupingSeparator);
         GWizUtils.LogError("lastOperationStatus = " + _loc2_.lastOperationStatus);
         GWizUtils.LogError("leadingZero = " + _loc2_.leadingZero);
         GWizUtils.LogError("negativeNumberFormat = " + _loc2_.negativeNumberFormat);
         GWizUtils.LogError("requestedLocaleIDName = " + _loc2_.requestedLocaleIDName);
         GWizUtils.LogError("trailingZeros = " + _loc2_.trailingZeros);
         GWizUtils.LogError("useGrouping = " + _loc2_.useGrouping);
         GWizUtils.LogError("******************** INFO END ***********************\n");
      }
      
      private function _GWizDebugLogReader_Array1_c() : Array
      {
         return [this._GWizDebugLogReader_VGroup1_c()];
      }
      
      private function _GWizDebugLogReader_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizDebugLogReader_Label1_i(),this._GWizDebugLogReader_TextArea1_i(),this._GWizDebugLogReader_CheckBox1_i(),this._GWizDebugLogReader_Button1_i(),this._GWizDebugLogReader_Spacer1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDebugLogReader_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "G-Wizard Debugging Log";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.id = "logLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.logLabel = _loc1_;
         BindingManager.executeBindings(this,"logLabel",this.logLabel);
         return _loc1_;
      }
      
      private function _GWizDebugLogReader_TextArea1_i() : TextArea
      {
         var _loc1_:TextArea = new TextArea();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.id = "viewer";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.viewer = _loc1_;
         BindingManager.executeBindings(this,"viewer",this.viewer);
         return _loc1_;
      }
      
      private function _GWizDebugLogReader_CheckBox1_i() : CheckBox
      {
         var _loc1_:CheckBox = new CheckBox();
         _loc1_.label = "Write log to logfile.txt";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.__logToFile_click);
         _loc1_.id = "logToFile";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.logToFile = _loc1_;
         BindingManager.executeBindings(this,"logToFile",this.logToFile);
         return _loc1_;
      }
      
      public function __logToFile_click(param1:MouseEvent) : void
      {
         this.doLogging();
      }
      
      private function _GWizDebugLogReader_Button1_i() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Add Info";
         _loc1_.addEventListener("click",this.__infoBtn_click);
         _loc1_.id = "infoBtn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.infoBtn = _loc1_;
         BindingManager.executeBindings(this,"infoBtn",this.infoBtn);
         return _loc1_;
      }
      
      public function __infoBtn_click(param1:MouseEvent) : void
      {
         this.addInfo();
      }
      
      private function _GWizDebugLogReader_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 5;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizDebugLogReader_Window1_creationComplete(param1:FlexEvent) : void
      {
         this.initDebugOpts();
      }
      
      public function ___GWizDebugLogReader_Window1_close(param1:Event) : void
      {
         logWindow = null;
      }
      
      private function _GWizDebugLogReader_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = GWizUtils.errorLog;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"viewer.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get infoBtn() : Button
      {
         return this._1945385678infoBtn;
      }
      
      public function set infoBtn(param1:Button) : void
      {
         var _loc2_:Object = this._1945385678infoBtn;
         if(_loc2_ !== param1)
         {
            this._1945385678infoBtn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"infoBtn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get logLabel() : Label
      {
         return this._1995593232logLabel;
      }
      
      public function set logLabel(param1:Label) : void
      {
         var _loc2_:Object = this._1995593232logLabel;
         if(_loc2_ !== param1)
         {
            this._1995593232logLabel = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"logLabel",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get logToFile() : CheckBox
      {
         return this._1974980347logToFile;
      }
      
      public function set logToFile(param1:CheckBox) : void
      {
         var _loc2_:Object = this._1974980347logToFile;
         if(_loc2_ !== param1)
         {
            this._1974980347logToFile = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"logToFile",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get viewer() : TextArea
      {
         return this._816631278viewer;
      }
      
      public function set viewer(param1:TextArea) : void
      {
         var _loc2_:Object = this._816631278viewer;
         if(_loc2_ !== param1)
         {
            this._816631278viewer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"viewer",_loc2_,param1));
            }
         }
      }
   }
}
