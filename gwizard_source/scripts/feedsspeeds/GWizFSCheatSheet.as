package feedsspeeds
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.collections.ArrayList;
   import mx.collections.IList;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import spark.components.DataGrid;
   import spark.components.Window;
   import spark.components.gridClasses.GridColumn;
   import utils.ColorPalette;
   import utils.GATracker;
   
   use namespace mx_internal;
   
   public class GWizFSCheatSheet extends Window implements IBindingClient
   {
      
      private static var CheatWin:GWizFSCheatSheet;
      
      private static var _2017305120Cheats:ArrayCollection = new ArrayCollection([{
         "goal":"Faster Cuts - Shorter Cycle Times",
         "change":"(Increase MRR for shorter cycle times)\n\n" + "Find optimal Cut Depth + Cut Width combo with CADCAM Wizards\n" + "Use Cut Optimizer to maximize either Cut Depth or Cut Width\n" + "Use an HSM Toolpath\n" + "Use better cutters and enter Mfg\'s Data so G-Wizard will take advantage\n" + "Try a serrated rougher\n" + "Turn on TSC or PCN coolant options\n" + "Use a more rigid setup or HMC and set the dropdown to \'Rigid\' instead of \'Normal\' on the Results row\n" + "Set Tortoise-Hare all the way right"
      },{
         "goal":"Longer Tool Life",
         "change":"(Emphasize Tool Life over production speed)\n\n" + "Set Tortoise-Hare further left\n" + "Reduce RPM\'s\n" + "Set Spindle % Adjustment on machine profile lower"
      },{
         "goal":"Better Surface Finish",
         "change":"(Less chipload per rpm = better finish)\n\n" + "Set Tortoise-Hare further left\n"
      },{
         "goal":"More Conservative for Small Machines",
         "change":"(Small machines are less rigid and need less aggressive cuts)\n\n" + "Set Tortoise-Hare further left\n" + "Try weight limited power curve in machine profile\n" + "Use smaller tools\n" + "Manually reduce the spindle power limit"
      },{
         "goal":"Slower RPMs (Hit upper limit)",
         "change":"(Slower RPMs are always good for tool life)\n\n" + "Manually override RPM to lower value\n" + "Use a larger diameter tool\n" + "Set Tortoise-Hare further left\n" + "Increase Cut Depth"
      },{
         "goal":"Faster RPMs (Hit lower limit)",
         "change":"(Careful: Too many RPMs will burn the tool!)\n\n" + "Use a smaller diameter tool (see Tips for size)\n" + "Use an HSM toolpath\n" + "Use a carbide instead of HSS tool\n" + "Use a tool with better coatings\n" + "Reduce Cut Depth if Axial is > 50%"
      },{
         "goal":"Faster Feedrate (For faster cycle times)",
         "change":"(Careful: Too much chipload will break cutters!)\n\n" + "Use a cutter with more flutes (careful, no more than 3 flutes in aluminum!)\n" + "Use a bigger cutter or a rougher that can take a bigger bite.\n" + "Move Tortoise-Hare right\n" + "Use an HSM toolpath\n" + "Reduce cut depth\n" + "Reduce cut width\n" + "Use TSC or PCN coolant options\n" + "Try Mfg data\n" + "With indexable cutters, try one with a lead angle < 90 degrees"
      },{
         "goal":"Slower Feedrate (Hit limit)",
         "change":"(Careful: Too slow causes rubbing which is hard on tool life!)\n" + "(Good News: G-Wizard gives a rubbing warning under Tips if that\'s a problem.)\n\n" + "Reduce rpms and feedrate will reduce\n" + "Move Tortoise-Hare slider left\n" + "Use a cutter with fewer flutes"
      },{
         "goal":"Reduce Tool Deflection",
         "change":"(Tool Deflection is hard on tool life and can excite chatter)\n\n" + "Use a Carbide instead of HSS cutter\n" + "Use a larger diameter cutter\n" + "Reduce stickout\n" + "Increase RPM. Same spindle power (HP) at higher RPM = less torque = lower cutting forces.\n" + "Use Cut Optimizer to reduce Cut Depth or Cut Width\n" + "Take a less aggressive cut that generates lower cutting forces.  Best way is to move Tortoise-Hare to the left."
      },{
         "goal":"Less Power Req\'d (Hit Limit or Stalled Spindle)",
         "change":"Reduce spindle power limit on machine profile or manually\n" + "Use a spindle power curve on machine profile\n" + "Use a smaller tool"
      },{
         "goal":"Less Chip Welding",
         "change":"(Chips can weld to tool in aluminum and some other materials)\n\n" + "Use mist or flood coolant to lubricate\n" + "Be paranoid about chip clearing\n" + "Take extremely shallow cut depths"
      },{
         "goal":"Less Heat",
         "change":"(Heat can melt or burn some materials)\n\n" + "Make sure there\'s no rubbing warning under Tips\n" + "Reduce RPMs\n" + "Reduce Cut Depth and/or Width\n" + "Use Coolant"
      },{
         "goal":"Avoid Rubbing",
         "change":"(Rubbing reduces tool life.  G-Wizard warns of rubbing under Tips)\n\n" + "Increase feedrate\n" + "Reduce RPMs"
      }]);
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _1361529344cheats:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _209262271labelBackgroundColor:uint;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizFSCheatSheet()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._209262271labelBackgroundColor = ColorPalette.gray4;
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizFSCheatSheet_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_feedsspeeds_GWizFSCheatSheetWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizFSCheatSheet[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.title = "G-Wizard Feeds and Speeds Cheat Sheet";
         this.width = 640;
         this.height = 480;
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizFSCheatSheet_Array1_c);
         this.addEventListener("close",this.___GWizFSCheatSheet_Window1_close);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function doCheatSheet() : void
      {
         if(!CheatWin)
         {
            GATracker.logPageView("CheatSheet","CheatSheet");
            CheatWin = new GWizFSCheatSheet();
            CheatWin.open();
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizFSCheatSheet._watcherSetupUtil = param1;
      }
      
      [Bindable(event="propertyChange")]
      private static function get Cheats() : ArrayCollection
      {
         return GWizFSCheatSheet._2017305120Cheats;
      }
      
      private static function set Cheats(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizFSCheatSheet._2017305120Cheats;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizFSCheatSheet,"Cheats",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
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
            this.backgroundAlpha = 0.3;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onClose() : void
      {
         if(CheatWin)
         {
            CheatWin.close();
            CheatWin = null;
         }
      }
      
      private function _GWizFSCheatSheet_Array1_c() : Array
      {
         return [this._GWizFSCheatSheet_DataGrid1_i()];
      }
      
      private function _GWizFSCheatSheet_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.variableRowHeight = true;
         _loc1_.columns = this._GWizFSCheatSheet_ArrayList1_c();
         _loc1_.id = "cheats";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.cheats = _loc1_;
         BindingManager.executeBindings(this,"cheats",this.cheats);
         return _loc1_;
      }
      
      private function _GWizFSCheatSheet_ArrayList1_c() : ArrayList
      {
         var _loc1_:ArrayList = new ArrayList();
         _loc1_.source = [this._GWizFSCheatSheet_GridColumn1_c(),this._GWizFSCheatSheet_GridColumn2_c()];
         return _loc1_;
      }
      
      private function _GWizFSCheatSheet_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "I Want...";
         _loc1_.dataField = "goal";
         return _loc1_;
      }
      
      private function _GWizFSCheatSheet_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Change...";
         _loc1_.dataField = "change";
         return _loc1_;
      }
      
      public function ___GWizFSCheatSheet_Window1_close(param1:Event) : void
      {
         this.onClose();
      }
      
      private function _GWizFSCheatSheet_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,function():uint
         {
            return labelBackgroundColor;
         },function(param1:uint):void
         {
            this.setStyle("backgroundColor",param1);
         },"this.backgroundColor");
         result[1] = new Binding(this,function():IList
         {
            return Cheats;
         },null,"cheats.dataProvider");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get cheats() : DataGrid
      {
         return this._1361529344cheats;
      }
      
      public function set cheats(param1:DataGrid) : void
      {
         var _loc2_:Object = this._1361529344cheats;
         if(_loc2_ !== param1)
         {
            this._1361529344cheats = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"cheats",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      private function get labelBackgroundColor() : uint
      {
         return this._209262271labelBackgroundColor;
      }
      
      private function set labelBackgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._209262271labelBackgroundColor;
         if(_loc2_ !== param1)
         {
            this._209262271labelBackgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"labelBackgroundColor",_loc2_,param1));
            }
         }
      }
   }
}
