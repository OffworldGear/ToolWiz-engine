package notebook
{
   import comps.GWizPopUpManager;
   import comps.GWizWebFileBrowser;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   
   public class GWizNotebookDataImport
   {
      
      public static const NOTEBOOK_DATA_CATALOG:String = "http://www.cnccookbook.com/img/GWizard/Downloads/NotebookData/NotebookCatalog.csv";
       
      
      private var notebookDataCols:Array;
      
      private var notebookDataPicker:GWizWebFileBrowser = null;
      
      public var loadCustData:Function = null;
      
      public function GWizNotebookDataImport(param1:Boolean = false)
      {
         this.notebookDataCols = ["Category","Description"];
         super();
         var _loc2_:GWizWebFileBrowser = GWizWebFileBrowser(GWizPopUpManager.createPopUp(DisplayObject(GWizSettings.docWindow),GWizWebFileBrowser,true));
         if(_loc2_)
         {
            this.notebookDataPicker = _loc2_;
            this.notebookDataPicker.setup("Import Notebook Data",NOTEBOOK_DATA_CATALOG,this.notebookDataCols,this.dataLoad,false,param1);
         }
      }
      
      private function dataLoad(param1:String, param2:String) : void
      {
         if(this.loadCustData != null)
         {
            this.loadCustData(param1,param2);
         }
         this.notebookDataPicker.close();
      }
   }
}
