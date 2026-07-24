package comps
{
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import mx.binding.BindingManager;
   import mx.collections.ArrayCollection;
   import mx.controls.HRule;
   import mx.controls.Spacer;
   import mx.core.ClassFactory;
   import mx.core.DeferredInstanceFromFunction;
   import mx.core.IFlexModuleFactory;
   import mx.events.CloseEvent;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.managers.PopUpManager;
   import spark.components.Button;
   import spark.components.DataGrid;
   import spark.components.Label;
   import spark.components.TitleWindow;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import spark.events.GridEvent;
   
   public class GWizDataGridSettings extends TitleWindow
   {
      
      private static const log:ILogger = Log.getLogger("GWizDataGridSettings");
       
      
      private var _2105854020columnGrid:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public var parentGrid:GWizDataGrid;
      
      private var dragging:Boolean = false;
      
      private var draggingIndex:int;
      
      public function GWizDataGridSettings()
      {
         super();
         mx_internal::_document = this;
         this.width = 250;
         this.title = "Column Editor";
         this.mxmlContentFactory = new DeferredInstanceFromFunction(this._GWizDataGridSettings_Array1_c);
         this.addEventListener("creationComplete",this.___GWizDataGridSettings_TitleWindow1_creationComplete);
         this.addEventListener("keyDown",this.___GWizDataGridSettings_TitleWindow1_keyDown);
         this.addEventListener("close",this.___GWizDataGridSettings_TitleWindow1_close);
      }
      
      public static function create(param1:GWizDataGrid) : GWizDataGridSettings
      {
         var _loc2_:GWizDataGridSettings = new GWizDataGridSettings();
         PopUpManager.addPopUp(_loc2_,param1,true);
         _loc2_.parentGrid = param1;
         _loc2_.setFocus();
         return _loc2_;
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
      
      private function handleKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.charCode == Keyboard.ESCAPE)
         {
            dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
         }
      }
      
      protected function closeHandler(param1:CloseEvent) : void
      {
         GWizDataGridConfigs.getInstance().updateConfig(this.parentGrid);
         PopUpManager.removePopUp(this);
      }
      
      protected function onCC(param1:FlexEvent) : void
      {
         var _loc2_:Point = this.parentGrid.localToGlobal(new Point(this.parentGrid.width - width,this.parentGrid.columnHeaderGroup.height));
         x = _loc2_.x;
         y = _loc2_.y;
         this.columnGrid.dataProvider = this.parentGrid.columns;
         addEventListener(GridEvent.GRID_MOUSE_DRAG,this.handleDragging);
         addEventListener(GridEvent.GRID_MOUSE_UP,this.handleMouseUp);
      }
      
      private function handleDragging(param1:GridEvent) : void
      {
         if(!this.dragging)
         {
            this.dragging = true;
            this.draggingIndex = param1.rowIndex;
         }
         if(param1.rowIndex == -1)
         {
            return;
         }
         if(this.draggingIndex != param1.rowIndex)
         {
            this.moveRow(this.draggingIndex,param1.rowIndex);
            this.draggingIndex = param1.rowIndex;
         }
      }
      
      private function handleMouseUp(param1:GridEvent) : void
      {
         if(!this.dragging)
         {
            return;
         }
         this.dragging = false;
         if(param1.rowIndex != -1 && this.draggingIndex != param1.rowIndex)
         {
            this.moveRow(this.draggingIndex,param1.rowIndex);
         }
      }
      
      private function moveRow(param1:int, param2:int) : void
      {
         if(param1 == param2)
         {
            return;
         }
         var _loc3_:Object = this.parentGrid.columns.removeItemAt(param1);
         this.parentGrid.columns.addItemAt(_loc3_,param2);
         this.columnGrid.selectedIndex = param2;
         this.parentGrid.columnMoved(param1,param2);
      }
      
      protected function resetToFactorySettings(param1:MouseEvent) : void
      {
         GWizDataGridConfigs.getInstance().resetConfig(this.parentGrid);
         this.parentGrid.configure();
         this.columnGrid.dataProvider = this.parentGrid.columns;
      }
      
      private function _GWizDataGridSettings_Array1_c() : Array
      {
         return [this._GWizDataGridSettings_VGroup1_c()];
      }
      
      private function _GWizDataGridSettings_VGroup1_c() : VGroup
      {
         var _loc1_:VGroup = new VGroup();
         _loc1_.percentWidth = 100;
         _loc1_.horizontalAlign = "center";
         _loc1_.mxmlContent = [this._GWizDataGridSettings_DataGrid1_i(),this._GWizDataGridSettings_HRule1_c(),this._GWizDataGridSettings_Label1_c(),this._GWizDataGridSettings_Button1_c(),this._GWizDataGridSettings_Spacer1_c()];
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.columns = this._GWizDataGridSettings_ArrayCollection1_c();
         _loc1_.setStyle("borderVisible",false);
         _loc1_.id = "columnGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.columnGrid = _loc1_;
         BindingManager.executeBindings(this,"columnGrid",this.columnGrid);
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.source = [this._GWizDataGridSettings_GridColumn1_c(),this._GWizDataGridSettings_GridColumn2_c(),this._GWizDataGridSettings_GridColumn3_c()];
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_GridColumn1_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Show";
         _loc1_.width = 50;
         _loc1_.resizable = false;
         _loc1_.itemRenderer = this._GWizDataGridSettings_ClassFactory1_c();
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_ClassFactory1_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizDataGridSettingsInnerClass0;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_GridColumn2_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Name";
         _loc1_.resizable = false;
         _loc1_.itemRenderer = this._GWizDataGridSettings_ClassFactory2_c();
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_ClassFactory2_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizDataGridSettingsInnerClass1;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_GridColumn3_c() : GridColumn
      {
         var _loc1_:GridColumn = new GridColumn();
         _loc1_.headerText = "Sort";
         _loc1_.width = 40;
         _loc1_.resizable = false;
         _loc1_.itemRenderer = this._GWizDataGridSettings_ClassFactory3_c();
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_ClassFactory3_c() : ClassFactory
      {
         var _loc1_:ClassFactory = new ClassFactory();
         _loc1_.generator = GWizDataGridSettingsInnerClass2;
         _loc1_.properties = {"outerDocument":this};
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_HRule1_c() : HRule
      {
         var _loc1_:HRule = new HRule();
         _loc1_.percentWidth = 100;
         _loc1_.height = 1;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_Label1_c() : Label
      {
         var _loc1_:Label = new Label();
         _loc1_.text = "Settings will be saved";
         _loc1_.setStyle("fontSize",12);
         _loc1_.setStyle("fontWeight","bold");
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      private function _GWizDataGridSettings_Button1_c() : Button
      {
         var _loc1_:Button = new Button();
         _loc1_.label = "Restore factory settings";
         _loc1_.setStyle("fontSize",10);
         _loc1_.setStyle("fontWeight","bold");
         _loc1_.addEventListener("click",this.___GWizDataGridSettings_Button1_click);
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizDataGridSettings_Button1_click(param1:MouseEvent) : void
      {
         this.resetToFactorySettings(param1);
      }
      
      private function _GWizDataGridSettings_Spacer1_c() : Spacer
      {
         var _loc1_:Spacer = new Spacer();
         _loc1_.height = 1;
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         return _loc1_;
      }
      
      public function ___GWizDataGridSettings_TitleWindow1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC(param1);
      }
      
      public function ___GWizDataGridSettings_TitleWindow1_keyDown(param1:KeyboardEvent) : void
      {
         this.handleKeyDown(param1);
      }
      
      public function ___GWizDataGridSettings_TitleWindow1_close(param1:CloseEvent) : void
      {
         this.closeHandler(param1);
      }
      
      [Bindable(event="propertyChange")]
      public function get columnGrid() : DataGrid
      {
         return this._2105854020columnGrid;
      }
      
      public function set columnGrid(param1:DataGrid) : void
      {
         var _loc2_:Object = this._2105854020columnGrid;
         if(_loc2_ !== param1)
         {
            this._2105854020columnGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"columnGrid",_loc2_,param1));
            }
         }
      }
   }
}
