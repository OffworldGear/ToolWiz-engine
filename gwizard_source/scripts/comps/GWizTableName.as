package comps
{
   import configinfo.GWizSettings;
   import flash.events.Event;
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
   
   use namespace mx_internal;
   
   public class GWizTableName extends GWizPopUp implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1078357251theLabel:Label;
      
      private var _1350627684theName:TextInput;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _114225str:String = null;
      
      private var _979805852prompt:String = "Table Name";
      
      public var onDone:Function = null;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizTableName()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizTableName_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizTableNameWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizTableName[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.okLabel = "Create Tool Table";
         this.title = "Create Tool Table";
         this.width = 400;
         this.mxmlContent = [this._GWizTableName_HGroup1_c(),this._GWizTableName_Spacer1_c()];
         this.addEventListener("creationComplete",this.___GWizTableName_GWizPopUp1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function toolTableName(param1:Function, param2:String = "My New Table") : void
      {
         var _loc3_:GWizTableName = GWizTableName(GWizPopUpManager.createPopUp(null,GWizTableName,true));
         if(_loc3_)
         {
            _loc3_.str = param2;
            _loc3_.onDone = param1;
         }
         GWizSettings.cribData.flushGetCribEntryCache();
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizTableName._watcherSetupUtil = param1;
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
            this.fontWeight = "bold";
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
         this.theName.setFocus();
      }
      
      override public function onOk(param1:Event) : void
      {
         super.close();
         if(this.onDone != null && this.theName.text.length > 0)
         {
            this.onDone(this.theName.text,null);
         }
      }
      
      override public function onCancel(param1:Event) : void
      {
         super.close();
      }
      
      private function _GWizTableName_HGroup1_c() : HGroup
      {
         var _loc1_:HGroup = new HGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.verticalAlign = "middle";
         _loc1_.mxmlContent = [this._GWizTableName_Label1_i(),this._GWizTableName_TextInput1_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizTableName_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.setStyle("color",16777215);
         _loc1_.id = "theLabel";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theLabel = _loc1_;
         BindingManager.executeBindings(this,"theLabel",this.theLabel);
         return _loc1_;
      }
      
      private function _GWizTableName_TextInput1_i() : TextInput
      {
         var _loc1_:TextInput = new TextInput();
         _loc1_.percentWidth = 100;
         _loc1_.id = "theName";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theName = _loc1_;
         BindingManager.executeBindings(this,"theName",this.theName);
         return _loc1_;
      }
      
      private function _GWizTableName_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 20;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizTableName_GWizPopUp1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizTableName_bindingsSetup() : Array
      {
         var _loc1_:Array = [];
         _loc1_[0] = new Binding(this,null,null,"theLabel.text","prompt");
         _loc1_[1] = new Binding(this,null,null,"theName.text","str");
         return _loc1_;
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
      public function get theName() : TextInput
      {
         return this._1350627684theName;
      }
      
      public function set theName(param1:TextInput) : void
      {
         var _loc2_:Object = this._1350627684theName;
         if(_loc2_ !== param1)
         {
            this._1350627684theName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get str() : String
      {
         return this._114225str;
      }
      
      public function set str(param1:String) : void
      {
         var _loc2_:Object = this._114225str;
         if(_loc2_ !== param1)
         {
            this._114225str = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"str",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get prompt() : String
      {
         return this._979805852prompt;
      }
      
      public function set prompt(param1:String) : void
      {
         var _loc2_:Object = this._979805852prompt;
         if(_loc2_ !== param1)
         {
            this._979805852prompt = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"prompt",_loc2_,param1));
            }
         }
      }
   }
}
