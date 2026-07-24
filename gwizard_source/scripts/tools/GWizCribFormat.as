package tools
{
   import comps.GWizPopUp;
   import comps.GWizPopUpManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.List;
   import spark.components.RadioButtonGroup;
   import spark.components.VGroup;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCribFormat extends GWizPopUp implements IBindingClient
   {
      
      public static const CSV_DEFAULT_IMPORT:int = 0;
      
      public static const MACH3_IMPORT:int = 1;
      
      public static const F360_CSV_IMPORT:int = 2;
      
      public static const F360_TSV_IMPORT:int = 3;
      
      public static var importFormats:ArrayCollection = new ArrayCollection([{"name":"CSV - GW Calculator Default"},{"name":"Mach3 Tool Table (*.dat)"},{"name":"Fusion360 Tool Table (*.csv)"},{"name":"Fusion360 Tool Table (*.tsv)"}]);
      
      public static const CSV_DEFAULT_EXPORT:int = 0;
      
      public static const MACH3_EXPORT:int = 1;
      
      public static var exportFormats:ArrayCollection = new ArrayCollection([{"name":"GW Calculator Tool Crib (*.csv)"},{"name":"Mach3 Tool Table (*.dat)"}]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1422536572addGrp:RadioButtonGroup;
      
      private var _1270602472fmtGrp:RadioButtonGroup;
      
      private var _1163946230formatSelector:List;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var nextStep:Function;
      
      private var _2125055720importMode:Boolean = false;
      
      private var _896505829source:ArrayCollection;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCribFormat()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCribFormat_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizCribFormatWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCribFormat[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Tool Table Format...";
         this.width = 300;
         this.height = 300;
         this.mxmlContent = [this._GWizCribFormat_VGroup1_c()];
         this._GWizCribFormat_RadioButtonGroup2_i();
         this._GWizCribFormat_RadioButtonGroup1_i();
         this.addEventListener("creationComplete",this.___GWizCribFormat_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function getCribFormat(param1:Boolean, param2:ArrayCollection, param3:Function, param4:Object) : void
      {
         var _loc5_:GWizCribFormat;
         (_loc5_ = GWizCribFormat(GWizPopUpManager.createPopUp(DisplayObject(param4),GWizCribFormat,true))).source = param2;
         _loc5_.nextStep = param3;
         _loc5_.importMode = param1;
         _loc5_.onCC();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCribFormat._watcherSetupUtil = param1;
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
      
      override public function onOk(param1:Event) : void
      {
         super.close();
         if(this.nextStep != null)
         {
            this.nextStep(this.source,this.formatSelector.selectedIndex,false);
         }
      }
      
      private function onCC() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         this.formatSelector.selectedIndex = 0;
         if(!GWizUtils.debug)
         {
            _loc1_ = 0;
            while(_loc1_ < importFormats.length)
            {
               _loc2_ = importFormats.getItemAt(_loc1_);
               if(_loc2_.hasOwnProperty("debug"))
               {
                  importFormats.removeItemAt(_loc1_);
               }
               _loc1_++;
            }
         }
      }
      
      private function _GWizCribFormat_RadioButtonGroup2_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"addGrp");
         this.addGrp = _loc1_;
         BindingManager.executeBindings(this,"addGrp",this.addGrp);
         return _loc1_;
      }
      
      private function _GWizCribFormat_RadioButtonGroup1_i() : RadioButtonGroup
      {
         var _loc1_:RadioButtonGroup = new RadioButtonGroup();
         _loc1_.initialized(this,"fmtGrp");
         this.fmtGrp = _loc1_;
         BindingManager.executeBindings(this,"fmtGrp",this.fmtGrp);
         return _loc1_;
      }
      
      private function _GWizCribFormat_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.mxmlContent = [this._GWizCribFormat_Label1_c(),this._GWizCribFormat_List1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribFormat_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "File Format";
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("fontSize",14);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribFormat_List1_i() : List
      {
         var _loc1_:List = new List();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.labelField = "name";
         _loc1_.id = "formatSelector";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.formatSelector = _loc1_;
         BindingManager.executeBindings(this,"formatSelector",this.formatSelector);
         return _loc1_;
      }
      
      public function ___GWizCribFormat_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCribFormat_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"formatSelector.dataProvider","source");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get addGrp() : RadioButtonGroup
      {
         return this._1422536572addGrp;
      }
      
      public function set addGrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1422536572addGrp;
         if(_loc2_ !== param1)
         {
            this._1422536572addGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"addGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get fmtGrp() : RadioButtonGroup
      {
         return this._1270602472fmtGrp;
      }
      
      public function set fmtGrp(param1:RadioButtonGroup) : void
      {
         var _loc2_:Object = this._1270602472fmtGrp;
         if(_loc2_ !== param1)
         {
            this._1270602472fmtGrp = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"fmtGrp",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get formatSelector() : List
      {
         return this._1163946230formatSelector;
      }
      
      public function set formatSelector(param1:List) : void
      {
         var _loc2_:Object = this._1163946230formatSelector;
         if(_loc2_ !== param1)
         {
            this._1163946230formatSelector = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"formatSelector",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get importMode() : Boolean
      {
         return this._2125055720importMode;
      }
      
      private function set importMode(param1:Boolean) : void
      {
         var _loc2_:Object = this._2125055720importMode;
         if(_loc2_ !== param1)
         {
            this._2125055720importMode = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"importMode",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get source() : ArrayCollection
      {
         return this._896505829source;
      }
      
      public function set source(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this._896505829source;
         if(_loc2_ !== param1)
         {
            this._896505829source = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"source",_loc2_,param1));
            }
         }
      }
   }
}
