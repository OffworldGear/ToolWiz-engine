package tools
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import spark.components.DropDownList;
   import spark.layouts.VerticalLayout;
   
   use namespace mx_internal;
   
   public class GWizToolHolderDDList extends DropDownList implements IBindingClient
   {
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizToolHolderDDList()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         var bindings:Array = this._GWizToolHolderDDList_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_tools_GWizToolHolderDDListWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizToolHolderDDList[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.labelField = "name";
         this.addEventListener("creationComplete",this.___GWizToolHolderDDList_DropDownList1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizToolHolderDDList._watcherSetupUtil = param1;
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
         this.layout = new VerticalLayout();
         this.layout["requestedMaxRowCount"] = 10;
      }
      
      public function getValue() : String
      {
         return this.selectedItem.name;
      }
      
      public function setValue(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < GWizToolCribEntry.toolHolderTypes.length)
         {
            _loc3_ = GWizToolCribEntry.toolHolderTypes.getItemAt(_loc2_).name;
            if(param1 == _loc3_)
            {
               this.selectedIndex = _loc2_;
               return;
            }
            _loc2_++;
         }
         this.selectedIndex = 0;
      }
      
      public function ___GWizToolHolderDDList_DropDownList1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizToolHolderDDList_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizToolCribEntry.toolHolderTypes;
         },null,"this.dataProvider");
         return result;
      }
   }
}
