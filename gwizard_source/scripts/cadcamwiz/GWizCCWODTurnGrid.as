package cadcamwiz
{
   import flash.utils.getDefinitionByName;
   import mx.binding.Binding;
   import mx.binding.BindingManager;
   import mx.binding.IBindingClient;
   import mx.binding.IWatcherSetupUtil2;
   import mx.collections.ArrayCollection;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DataGrid;
   import spark.components.Label;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import spark.events.GridItemEditorEvent;
   import utils.ColorPalette;
   import utils.GWizUtils;
   
   use namespace mx_internal;
   
   public class GWizCCWODTurnGrid extends VGroup implements IBindingClient
   {
      
      private static const log:ILogger = Log.getLogger("GWizCCWODTurnGrid");
      
      public static const CORNER_NONE:String = "None";
      
      public static const CORNER_RADIUS:String = "Radius";
      
      public static const CORNER_CHAMFER:String = "Chamfer";
      
      public static var recalc:Function;
      
      private static var savedTurningPlan:ArrayCollection;
      
      private static var _watcherSetupUtil:IWatcherSetupUtil2;
       
      
      private var _1294667812errMsg:Label;
      
      private var _1022160910odTurn:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _130506091visibleRows:int = 5;
      
      private var _turningPlan:ArrayCollection;
      
      mx_internal var _bindings:Array;
      
      mx_internal var _watchers:Array;
      
      mx_internal var _bindingsByDestination:Object;
      
      mx_internal var _bindingsBeginWithWord:Object;
      
      public function GWizCCWODTurnGrid()
      {
         var target:Object = null;
         var watcherSetupUtilClass:Object = null;
         this._turningPlan = new ArrayCollection([]);
         this._bindings = [];
         this._watchers = [];
         this._bindingsByDestination = {};
         this._bindingsBeginWithWord = {};
         super();
         mx_internal::_document = this;
         var bindings:Array = this._GWizCCWODTurnGrid_bindingsSetup();
         var watchers:Array = [];
         target = this;
         if(_watcherSetupUtil == null)
         {
            watcherSetupUtilClass = getDefinitionByName("_cadcamwiz_GWizCCWODTurnGridWatcherSetupUtil");
            watcherSetupUtilClass["init"](null);
         }
         _watcherSetupUtil.setup(this,function(param1:String):*
         {
            return target[param1];
         },function(param1:String):*
         {
            return GWizCCWODTurnGrid[param1];
         },bindings,watchers);
         mx_internal::_bindings = mx_internal::_bindings.concat(bindings);
         mx_internal::_watchers = mx_internal::_watchers.concat(watchers);
         this.percentWidth = 100;
         this.mxmlContent = [this._GWizCCWODTurnGrid_VGroup2_c()];
         this.addEventListener("creationComplete",this.___GWizCCWODTurnGrid_VGroup1_creationComplete);
         var i:uint = 0;
         while(i < bindings.length)
         {
            Binding(bindings[i]).execute();
            i++;
         }
      }
      
      public static function set watcherSetupUtil(param1:IWatcherSetupUtil2) : void
      {
         GWizCCWODTurnGrid._watcherSetupUtil = param1;
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
      
      [Bindable(event="propertyChange")]
      public function get turningPlan() : ArrayCollection
      {
         return this._turningPlan;
      }
      
      private function set _979451662turningPlan(param1:ArrayCollection) : void
      {
         this._turningPlan = param1;
      }
      
      private function onCC() : void
      {
         if(GWizUtils.debug && this.turningPlan && !savedTurningPlan)
         {
            savedTurningPlan = this.turningPlan;
         }
         if(savedTurningPlan)
         {
            this.turningPlan = savedTurningPlan;
         }
         else
         {
            this.turningPlan = new ArrayCollection();
            this.turningPlan.addItem(this.newPlan(1,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(2,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(3,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(4,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(5,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(6,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(7,0,0,CORNER_NONE,0));
            this.turningPlan.addItem(this.newPlan(8,0,0,CORNER_NONE,0));
         }
      }
      
      private function newPlan(param1:int, param2:Number, param3:Number, param4:String, param5:Number) : Object
      {
         var _loc6_:Object;
         (_loc6_ = new Object()).num = param1;
         _loc6_.dia = param2;
         _loc6_.len = param3;
         _loc6_.corner = param4;
         _loc6_.radius = param5;
         return _loc6_;
      }
      
      private function doGridRecalc() : void
      {
         this.saveVars();
         this.turningPlan.refresh();
         if(recalc != null)
         {
            recalc();
         }
      }
      
      public function verifyGrid(param1:Number) : String
      {
         var _loc3_:Number = NaN;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         if(!this.turningPlan)
         {
            this.turningPlan = savedTurningPlan;
            if(!this.turningPlan)
            {
               return "";
            }
         }
         var _loc2_:* = "";
         this.saveVars();
         var _loc4_:int = 0;
         while(_loc4_ < this.turningPlan.length)
         {
            (_loc5_ = this.turningPlan.getItemAt(_loc4_)).dia = Number(_loc5_.dia);
            if(_loc4_ > 0)
            {
               if(_loc3_ < _loc5_.dia)
               {
                  return "Dia " + _loc4_ + " must be less than Dia " + (_loc4_ - 1);
               }
            }
            else if(param1 < _loc5_.dia)
            {
               return "Rapid To X must be greater than Dia 1 diameter.";
            }
            if(_loc5_.dia < 0)
            {
               return "Dia " + _loc4_ + " must be positive.";
            }
            if(_loc5_.len < 0)
            {
               return "Length of Dia " + _loc4_ + " must be positive.";
            }
            if(_loc5_.radius < 0)
            {
               _loc2_ = "Radius of Dia" + _loc4_ + " must be positive.";
            }
            if(_loc5_.radius > 0.5)
            {
               _loc2_ = "Radius of Dia" + _loc4_ + " must be less than 0.500.";
            }
            _loc6_ = 0;
            _loc7_ = _loc4_;
            while(_loc7_ < this.turningPlan.length)
            {
               if((_loc8_ = this.turningPlan.getItemAt(_loc7_)).dia <= 0)
               {
                  break;
               }
               _loc6_ += Number(_loc8_.len);
               if(GWizUtils.debug)
               {
                  log.debug("Diameter[" + _loc4_ + "] OAL = " + _loc6_ + " for entry[" + _loc7_ + "]");
               }
               _loc7_++;
            }
            _loc5_.OAL = Number(_loc6_);
            if(GWizUtils.debug)
            {
               log.debug("Final Diameter[" + _loc4_ + "] OAL = " + _loc5_.OAL);
            }
            _loc3_ = _loc5_.dia;
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function saveVars() : void
      {
         if(this.turningPlan)
         {
            savedTurningPlan = this.turningPlan;
         }
      }
      
      public function breakEdges(param1:Number) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.turningPlan.length)
         {
            _loc3_ = this.turningPlan.getItemAt(_loc2_);
            if(_loc3_.corner == CORNER_NONE)
            {
               _loc3_.corner = CORNER_RADIUS;
               _loc3_.radius = param1;
               this.turningPlan.itemUpdated(_loc3_,"corner",CORNER_NONE,CORNER_RADIUS);
               this.turningPlan.removeItemAt(_loc2_);
               _loc3_ = GWizUtils.clone(_loc3_);
               this.turningPlan.addItemAt(_loc3_,_loc2_);
            }
            _loc2_++;
         }
         this.turningPlan.refresh();
         this.saveVars();
      }
      
      private function _GWizCCWODTurnGrid_VGroup2_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.mxmlContent = [this._GWizCCWODTurnGrid_DataGrid1_i(),this._GWizCCWODTurnGrid_Label1_c(),this._GWizCCWODTurnGrid_Label2_i()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.editable = true;
         _loc1_.columns = this._GWizCCWODTurnGrid_ArrayCollection1_c();
         _loc1_.addEventListener("gridItemEditorSessionSave",this.__odTurn_gridItemEditorSessionSave);
         _loc1_.id = "odTurn";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.odTurn = _loc1_;
         BindingManager.executeBindings(this,"odTurn",this.odTurn);
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizCCWODTurnGrid_GridColumn1_c(),this._GWizCCWODTurnGrid_GridColumn2_c(),this._GWizCCWODTurnGrid_GridColumn3_c(),this._GWizCCWODTurnGrid_GridColumn4_c(),this._GWizCCWODTurnGrid_GridColumn5_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Dia #";
         _loc1_.dataField = "num";
         _loc1_.editable = false;
         _loc1_.width = 100;
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Diameter";
         _loc1_.dataField = "dia";
         _loc1_.editable = true;
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Length";
         _loc1_.dataField = "len";
         _loc1_.editable = true;
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_GridColumn4_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Corner";
         _loc1_.dataField = "corner";
         _loc1_.editable = true;
         _loc1_.rendererIsEditable = true;
         _loc1_.itemRenderer = this._GWizCCWODTurnGrid_ClassFactory1_c();
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizCCWODTurnGridRenderer;
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_GridColumn5_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Radius";
         _loc1_.dataField = "radius";
         _loc1_.editable = true;
         return _loc1_;
      }
      
      public function __odTurn_gridItemEditorSessionSave(param1:GridItemEditorEvent) : void
      {
         this.doGridRecalc();
      }
      
      private function _GWizCCWODTurnGrid_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Double click to edit, leave diameter or length 0 to ignore.";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizCCWODTurnGrid_Label2_i() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "";
         _loc1_.id = "errMsg";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.errMsg = _loc1_;
         BindingManager.executeBindings(this,"errMsg",this.errMsg);
         return _loc1_;
      }
      
      public function ___GWizCCWODTurnGrid_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      private function _GWizCCWODTurnGrid_bindingsSetup() : Array
      {
         var result:Array = [];
         result[0] = new Binding(this,null,null,"odTurn.dataProvider","turningPlan");
         result[1] = new Binding(this,null,null,"odTurn.requestedRowCount","visibleRows");
         result[2] = new Binding(this,function():uint
         {
            return ColorPalette.secondaryb1;
         },function(param1:uint):void
         {
            errMsg.setStyle("color",param1);
         },"errMsg.color");
         return result;
      }
      
      [Bindable(event="propertyChange")]
      public function get errMsg() : Label
      {
         return this._1294667812errMsg;
      }
      
      public function set errMsg(param1:Label) : void
      {
         var _loc2_:Object = this._1294667812errMsg;
         if(_loc2_ !== param1)
         {
            this._1294667812errMsg = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"errMsg",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get odTurn() : DataGrid
      {
         return this._1022160910odTurn;
      }
      
      public function set odTurn(param1:DataGrid) : void
      {
         var _loc2_:Object = this._1022160910odTurn;
         if(_loc2_ !== param1)
         {
            this._1022160910odTurn = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"odTurn",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get visibleRows() : int
      {
         return this._130506091visibleRows;
      }
      
      public function set visibleRows(param1:int) : void
      {
         var _loc2_:Object = this._130506091visibleRows;
         if(_loc2_ !== param1)
         {
            this._130506091visibleRows = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"visibleRows",_loc2_,param1));
            }
         }
      }
      
      public function set turningPlan(param1:ArrayCollection) : void
      {
         var _loc2_:Object = this.turningPlan;
         if(_loc2_ !== param1)
         {
            this._979451662turningPlan = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"turningPlan",_loc2_,param1));
            }
         }
      }
   }
}
