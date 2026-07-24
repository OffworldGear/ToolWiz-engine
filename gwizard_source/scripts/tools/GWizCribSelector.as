package tools
{
   import comps.GWizPopUp;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.DropDownList;
   import spark.components.Label;
   import spark.components.VGroup;
   
   use namespace mx_internal;
   
   public class GWizCribSelector extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1232234921CribChoice:DropDownList;
      
      private var _181947448listLbl:Label;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var toolCrib:GWizToolCrib;
      
      public var okHandler:Function;
      
      private var _607740351labelText:String = "Move to crib";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCribSelector()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCribSelector_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizCribSelectorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCribSelector[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "Move tool to new crib";
         this.okLabel = "Move";
         this.width = 400;
         this.mxmlContent = [this._GWizCribSelector_VGroup1_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCribSelector._watcherSetupUtil = param1;
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
         if(this.okHandler != null)
         {
            this.okHandler(param1);
         }
         super.close();
      }
      
      private function _GWizCribSelector_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.verticalAlign = "middle";
         _loc1_.horizontalAlign = "center";
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCribSelector_Label1_i(),this._GWizCribSelector_DropDownList1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCribSelector_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.id = "listLbl";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.listLbl = _loc1_;
         BindingManager.executeBindings(this,"listLbl",this.listLbl);
         return _loc1_;
      }
      
      private function _GWizCribSelector_DropDownList1_i() : DropDownList
      {
         var _loc1_:DropDownList = new DropDownList();
         _loc1_.labelField = "tabname";
         _loc1_.percentWidth = 100;
         _loc1_.id = "CribChoice";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.CribChoice = _loc1_;
         BindingManager.executeBindings(this,"CribChoice",this.CribChoice);
         return _loc1_;
      }
      
      private function _GWizCribSelector_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"listLbl.text","labelText");
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get CribChoice() : DropDownList
      {
         return this._1232234921CribChoice;
      }
      
      public function set CribChoice(param1:DropDownList) : void
      {
         var _loc2_:Object = this._1232234921CribChoice;
         if(_loc2_ !== param1)
         {
            this._1232234921CribChoice = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"CribChoice",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get listLbl() : Label
      {
         return this._181947448listLbl;
      }
      
      public function set listLbl(param1:Label) : void
      {
         var _loc2_:Object = this._181947448listLbl;
         if(_loc2_ !== param1)
         {
            this._181947448listLbl = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"listLbl",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get labelText() : String
      {
         return this._607740351labelText;
      }
      
      public function set labelText(param1:String) : void
      {
         var _loc2_:Object = this._607740351labelText;
         if(_loc2_ !== param1)
         {
            this._607740351labelText = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelText",_loc2_,param1));
            }
         }
      }
   }
}
