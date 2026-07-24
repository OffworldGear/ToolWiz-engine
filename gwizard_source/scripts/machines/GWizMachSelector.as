package machines
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.IList;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DropDownList;
   import spark.events.IndexChangeEvent;
   import utils.GATracker;
   
   use namespace mx_internal;
   
   public class GWizMachSelector extends DropDownList implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizMachSelector");
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var ownerName:String = "";
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizMachSelector()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         var bindings:Array = this._GWizMachSelector_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_machines_GWizMachSelectorWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizMachSelector[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.labelField = "name";
         this.toolTip = "Select which machine you\'re running";
         this.addEventListener("change",this.___GWizMachSelector_DropDownList1_change);
         this.addEventListener("creationComplete",this.___GWizMachSelector_DropDownList1_creationComplete);
         this.addEventListener("valueCommit",this.___GWizMachSelector_DropDownList1_valueCommit);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizMachSelector._watcherSetupUtil = param1;
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
      
      public function selectedName() : String
      {
         if(this.selectedIndex < 0)
         {
            this.selectedIndex = 0;
         }
         return this.selectedItem.name;
      }
      
      private function onCC() : void
      {
         GWizMachSettings.matchMachineCC.addFunction("GWizMachSelector",this.matchMachine,false);
         this.matchMachine();
      }
      
      private function onChange() : void
      {
         GWizMachSettings.currMachine = this.selectedItem.name;
         GATracker.logPageView("Machine/" + GWizMachSettings.currMachine,"Machine/" + GWizMachSettings.currMachine);
      }
      
      private function onValueCommit() : void
      {
         if(this.selectedIndex < 0)
         {
            if(GWizMachSettings.currMachine && GWizMachSettings.currMachine != "")
            {
               this.matchMachine();
            }
            log.debug("gotcha");
         }
      }
      
      private function matchMachine(param1:Object = null) : Boolean
      {
         this.selectedIndex = GWizMachSettings.lookupMachineIdx(GWizMachSettings.currMachine);
         return true;
      }
      
      public function ___GWizMachSelector_DropDownList1_change(param1:IndexChangeEvent) : void
      {
         this.onChange();
      }
      
      public function ___GWizMachSelector_DropDownList1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      public function ___GWizMachSelector_DropDownList1_valueCommit(param1:FlexEvent) : void
      {
         this.onValueCommit();
      }
      
      private function _GWizMachSelector_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():IList
         {
            return GWizMachSettings.MachinesList;
         },null,"this.dataProvider");
         return result;
      }
   }
}
