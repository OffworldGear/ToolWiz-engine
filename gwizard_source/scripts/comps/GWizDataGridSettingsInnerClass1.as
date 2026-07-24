package comps
{
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.Label;
   import spark.components.gridClasses.GridItemRenderer;
   
   use namespace mx_internal;
   
   public class GWizDataGridSettingsInnerClass1 extends GridItemRenderer implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      public var _GWizDataGridSettingsInnerClass1_Label1:Label;
      
      private var _88844982outerDocument:GWizDataGridSettings;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var oldCursor:String;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizDataGridSettingsInnerClass1()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizDataGridSettingsInnerClass1_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_comps_GWizDataGridSettingsInnerClass1WatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizDataGridSettingsInnerClass1[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.mxmlContent = [this._GWizDataGridSettingsInnerClass1_Label1_i()];
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizDataGridSettingsInnerClass1._watcherSetupUtil = param1;
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
      
      protected function mouseOverHandler(param1:MouseEvent) : void
      {
         this.oldCursor = Mouse.cursor;
         Mouse.cursor = MouseCursor.HAND;
      }
      
      protected function mouseOutHandler(param1:MouseEvent) : void
      {
         Mouse.cursor = this.oldCursor;
      }
      
      private function _GWizDataGridSettingsInnerClass1_Label1_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.setStyle("paddingTop",9);
         _loc1_.setStyle("paddingLeft",8);
         _loc1_.addEventListener("mouseOver",this.___GWizDataGridSettingsInnerClass1_Label1_mouseOver);
         _loc1_.addEventListener("mouseOut",this.___GWizDataGridSettingsInnerClass1_Label1_mouseOut);
         _loc1_.id = "_GWizDataGridSettingsInnerClass1_Label1";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this._GWizDataGridSettingsInnerClass1_Label1 = _loc1_;
         BindingManager.executeBindings(this,"_GWizDataGridSettingsInnerClass1_Label1",this._GWizDataGridSettingsInnerClass1_Label1);
         return _loc1_;
      }
      
      public function ___GWizDataGridSettingsInnerClass1_Label1_mouseOver(param1:MouseEvent) : void
      {
         this.mouseOverHandler(param1);
      }
      
      public function ___GWizDataGridSettingsInnerClass1_Label1_mouseOut(param1:MouseEvent) : void
      {
         this.mouseOutHandler(param1);
      }
      
      private function _GWizDataGridSettingsInnerClass1_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():String
         {
            var _loc1_:* = data.headerText;
            return _loc1_ == undefined ? null : String(_loc1_);
         },null,"_GWizDataGridSettingsInnerClass1_Label1.text");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizDataGridSettings
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizDataGridSettings) : void
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
   }
}
