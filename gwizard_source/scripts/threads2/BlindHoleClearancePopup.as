package threads2
{
   import comps.GWizPopUp;
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
   
   use namespace mx_internal;
   
   public class BlindHoleClearancePopup extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _451382607blindHoleClearanceLbl:Label;
      
      private var _88844982outerDocument:GWizThreadReference2;
      
      private var _1540671107tapType:DropDownList;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function BlindHoleClearancePopup()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._BlindHoleClearancePopup_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_threads2_BlindHoleClearancePopupWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return BlindHoleClearancePopup[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Blind Hole Tap Clearance Calculator";
         this.okLabel = "Close";
         this.cancelLabel = "";
         this.mxmlContent = [this._BlindHoleClearancePopup_HGroup1_c(),this._BlindHoleClearancePopup_HGroup2_c(),this._BlindHoleClearancePopup_Label4_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         BlindHoleClearancePopup._watcherSetupUtil = param1;
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
      }
      
      private function _BlindHoleClearancePopup_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._BlindHoleClearancePopup_Label1_c(),this._BlindHoleClearancePopup_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _BlindHoleClearancePopup_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Tap Type:";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _BlindHoleClearancePopup_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.percentWidth = 100;
         _loc1_.labelField = "label";
         _loc1_.selectedIndex = 0;
         _loc1_.addEventListener("valueCommit",this.__tapType_valueCommit);
         _loc1_.id = "tapType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.tapType = _loc1_;
         BindingManager.executeBindings(this,"tapType",this.tapType);
         return _loc1_;
      }
      
      public function __tapType_valueCommit(param1:FlexEvent) : void
      {
         this.blindHoleClearanceLbl.text = GWizAbstractThreadEngine.bhClearanceRecalc(this.tapType.selectedIndex);
      }
      
      private function _BlindHoleClearancePopup_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.mxmlContent = [this._BlindHoleClearancePopup_Label2_c(),this._BlindHoleClearancePopup_Label3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _BlindHoleClearancePopup_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Blind Hole Clearance = ";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _BlindHoleClearancePopup_Label3_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "??? (Choose tap type)";
         _loc1_.id = "blindHoleClearanceLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.blindHoleClearanceLbl = _loc1_;
         BindingManager.executeBindings(this,"blindHoleClearanceLbl",this.blindHoleClearanceLbl);
         return _loc1_;
      }
      
      private function _BlindHoleClearancePopup_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "( Bottom of tap to bottom of hole)";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _BlindHoleClearancePopup_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizAbstractThreadEngine.tapTypes;
         },null,"tapType.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get blindHoleClearanceLbl() : Label
      {
         return this._451382607blindHoleClearanceLbl;
      }
      
      public function set blindHoleClearanceLbl(param1:Label) : void
      {
         var _loc2_:Object = this._451382607blindHoleClearanceLbl;
         if(_loc2_ !== param1)
         {
            this._451382607blindHoleClearanceLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"blindHoleClearanceLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizThreadReference2
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizThreadReference2) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get tapType() : DropDownList
      {
         return this._1540671107tapType;
      }
      
      public function set tapType(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1540671107tapType;
         if(_loc2_ !== param1)
         {
            this._1540671107tapType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"tapType",_loc2_,param1));
            }
         }
      }
   }
}
