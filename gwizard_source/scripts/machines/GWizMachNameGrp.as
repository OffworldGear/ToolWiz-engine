package machines
{
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
   import spark.components.HGroup;
   import spark.components.Label;
   import spark.components.TextInput;
   import spark.components.VGroup;
   import spark.events.IndexChangeEvent;
   
   use namespace mx_internal;
   
   public class GWizMachNameGrp extends VGroup implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _2390542Make:TextInput;
      
      private var _74517257Model:TextInput;
      
      private var _185938140machName:TextInput;
      
      private var _185736237machType:GWizMachTypeSelector;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var typeChangeFcn:Function;
      
      public var altMachName:TextInput;
      
      public var altMachType:GWizMachTypeSelector;
      
      public var altMake:TextInput;
      
      public var altModel:TextInput;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMachNameGrp()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizMachNameGrp_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_machines_GWizMachNameGrpWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMachNameGrp[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizMachNameGrp_HGroup1_c(),this._GWizMachNameGrp_HGroup2_c(),this._GWizMachNameGrp_HGroup3_c(),this._GWizMachNameGrp_HGroup4_c()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMachNameGrp._watcherSetupUtil = param1;
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
      
      private function typeChange() : void
      {
         if(this.typeChangeFcn != null)
         {
            this.typeChangeFcn();
         }
      }
      
      private function typeValueCommit() : void
      {
         this.altMachType.selectedIndex = this.altMachType.selectedIndex;
      }
      
      private function _GWizMachNameGrp_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachNameGrp_Label1_c(),this._GWizMachNameGrp_Spacer1_c(),this._GWizMachNameGrp_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Name";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.editable = true;
         _loc1_.toolTip = "Name of this machine profile.";
         _loc1_.width = 200;
         _loc1_.addEventListener("valueCommit",this.__machName_valueCommit);
         _loc1_.id = "machName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machName = _loc1_;
         BindingManager.executeBindings(this,"machName",this.machName);
         return _loc1_;
      }
      
      public function __machName_valueCommit(param1:FlexEvent) : void
      {
         this.altMachName.text = this.machName.text;
      }
      
      private function _GWizMachNameGrp_HGroup2_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachNameGrp_Label2_c(),this._GWizMachNameGrp_Spacer2_c(),this._GWizMachNameGrp_GWizMachTypeSelector1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Label2_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Type";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Spacer2_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_GWizMachTypeSelector1_i() : GWizMachTypeSelector
      {
         var _loc1_:GWizMachTypeSelector = new GWizMachTypeSelector();
         _loc1_.addEventListener("change",this.__machType_change);
         _loc1_.addEventListener("valueCommit",this.__machType_valueCommit);
         _loc1_.id = "machType";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.machType = _loc1_;
         BindingManager.executeBindings(this,"machType",this.machType);
         return _loc1_;
      }
      
      public function __machType_change(param1:IndexChangeEvent) : void
      {
         this.typeChange();
      }
      
      public function __machType_valueCommit(param1:FlexEvent) : void
      {
         this.typeValueCommit();
      }
      
      private function _GWizMachNameGrp_HGroup3_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachNameGrp_Label3_c(),this._GWizMachNameGrp_Spacer3_c(),this._GWizMachNameGrp_TextInput2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Label3_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Make";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Spacer3_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_TextInput2_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.addEventListener("valueCommit",this.__Make_valueCommit);
         _loc1_.id = "Make";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Make = _loc1_;
         BindingManager.executeBindings(this,"Make",this.Make);
         return _loc1_;
      }
      
      public function __Make_valueCommit(param1:FlexEvent) : void
      {
         this.altMake.text = this.Make.text;
      }
      
      private function _GWizMachNameGrp_HGroup4_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizMachNameGrp_Label4_c(),this._GWizMachNameGrp_Spacer4_c(),this._GWizMachNameGrp_TextInput3_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Label4_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Model";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_Spacer4_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.percentWidth = 100;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizMachNameGrp_TextInput3_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.addEventListener("valueCommit",this.__Model_valueCommit);
         _loc1_.id = "Model";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.Model = _loc1_;
         BindingManager.executeBindings(this,"Model",this.Model);
         return _loc1_;
      }
      
      public function __Model_valueCommit(param1:FlexEvent) : void
      {
         this.altModel.text = this.Model.text;
      }
      
      private function _GWizMachNameGrp_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"machType.width");
         result[1] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"Make.width");
         result[2] = new Binding(this,function():Number
         {
            return machName.width;
         },null,"Model.width");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get Make() : TextInput
      {
         return this._2390542Make;
      }
      
      public function set Make(param1:TextInput) : void
      {
         var _loc2_:Object = this._2390542Make;
         if(_loc2_ !== param1)
         {
            this._2390542Make = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Make",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get Model() : TextInput
      {
         return this._74517257Model;
      }
      
      public function set Model(param1:TextInput) : void
      {
         var _loc2_:Object = this._74517257Model;
         if(_loc2_ !== param1)
         {
            this._74517257Model = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"Model",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machName() : TextInput
      {
         return this._185938140machName;
      }
      
      public function set machName(param1:TextInput) : void
      {
         var _loc2_:Object = this._185938140machName;
         if(_loc2_ !== param1)
         {
            this._185938140machName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get machType() : GWizMachTypeSelector
      {
         return this._185736237machType;
      }
      
      public function set machType(param1:GWizMachTypeSelector) : void
      {
         var _loc2_:Object = this._185736237machType;
         if(_loc2_ !== param1)
         {
            this._185736237machType = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"machType",_loc2_,param1));
            }
         }
      }
   }
}
