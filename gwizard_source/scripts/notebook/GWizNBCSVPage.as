package notebook
{
   import comps.GWizPopUpManager;
   import flash.filesystem.File;
   import mx.binding.BindingManager;
   import mx.collections.ArrayCollection;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import spark.components.DataGrid;
   import spark.components.VGroup;
   import spark.components.gridClasses.GridColumn;
   import utils.GWizCSVUtils;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizNBCSVPage extends VGroup
   {
      
      private static const log:ILogger = Log.getLogger("GWizNBCSVPage");
       
      
      private var _1350820009theGrid:DataGrid;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var url:String;
      
      private var creationComplete:Boolean = false;
      
      public function GWizNBCSVPage()
      {
         super();
         mx_internal::_document = this;
         this.percentWidth = 100;
         this.percentHeight = 100;
         this.mxmlContent = [this._GWizNBCSVPage_DataGrid1_i()];
         this.addEventListener("creationComplete",this.___GWizNBCSVPage_VGroup1_creationComplete);
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
      
      protected function creationCompleteHandler(param1:FlexEvent) : void
      {
         this.creationComplete = true;
         if(this.url != null)
         {
            this.loadURL();
         }
      }
      
      public function setURL(param1:String) : void
      {
         this.url = param1;
         if(this.creationComplete)
         {
            this.loadURL();
         }
      }
      
      private function loadURL() : Boolean
      {
         var ac:ArrayCollection = null;
         var myGridColumn:GridColumn = null;
         var i:int = 0;
         if(GWizStringUtils.isBlank(this.url))
         {
            return true;
         }
         var nbFile:File = new File(this.url);
         var error:Boolean = true;
         try
         {
            if(nbFile.exists)
            {
               ac = GWizCSVUtils.loadCSVFile(nbFile);
               if(ac)
               {
                  i = 0;
                  while(i < GWizCSVUtils.fieldList.length)
                  {
                     log.debug("Field " + i + " = \'" + GWizCSVUtils.fieldList[i] + "\'");
                     myGridColumn = new GridColumn();
                     myGridColumn.headerText = GWizCSVUtils.fieldList[i];
                     myGridColumn.dataField = GWizCSVUtils.fieldList[i];
                     this.theGrid.columns.addItem(myGridColumn);
                     i++;
                  }
                  ac.removeItemAt(0);
                  this.theGrid.dataProvider = ac;
                  error = false;
               }
            }
         }
         catch(e:Error)
         {
            GWizUtils.LogError("Notebook page \'" + url + "\' could not be loaded. " + e.message);
         }
         if(error)
         {
            GWizPopUpManager.Show("Notebook page \'" + this.url + "\' could not be loaded.","Error: Page Load Failed",GWizPopUpManager.ERROR);
         }
         return error;
      }
      
      private function _GWizNBCSVPage_DataGrid1_i() : DataGrid
      {
         var _loc1_:DataGrid = new DataGrid();
         _loc1_.percentWidth = 100;
         _loc1_.percentHeight = 100;
         _loc1_.columns = this._GWizNBCSVPage_ArrayCollection1_c();
         _loc1_.id = "theGrid";
         if(!_loc1_.document)
         {
            _loc1_.document = this;
         }
         this.theGrid = _loc1_;
         BindingManager.executeBindings(this,"theGrid",this.theGrid);
         return _loc1_;
      }
      
      private function _GWizNBCSVPage_ArrayCollection1_c() : ArrayCollection
      {
         var _loc1_:ArrayCollection = new ArrayCollection();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      public function ___GWizNBCSVPage_VGroup1_creationComplete(param1:FlexEvent) : void
      {
         this.creationCompleteHandler(param1);
      }
      
      [Bindable(event="propertyChange")]
      public function get theGrid() : DataGrid
      {
         return this._1350820009theGrid;
      }
      
      public function set theGrid(param1:DataGrid) : void
      {
         var _loc2_:Object = this._1350820009theGrid;
         if(_loc2_ !== param1)
         {
            this._1350820009theGrid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"theGrid",_loc2_,param1));
            }
         }
      }
   }
}
