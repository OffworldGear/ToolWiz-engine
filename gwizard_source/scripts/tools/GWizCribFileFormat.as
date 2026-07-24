package tools
{
   import comps.GWizFileBrowser;
   import flash.filesystem.File;
   import mx.collections.ArrayCollection;
   
   public class GWizCribFileFormat
   {
       
      
      public var cribFiles:GWizFileBrowser;
      
      public var toolsAC:ArrayCollection;
      
      public var importFcn:Function;
      
      public function GWizCribFileFormat()
      {
         super();
      }
      
      public function newDefaultTool() : Object
      {
         return {
            "key":0,
            "tabname":"",
            "machname":"",
            "slot":0,
            "description":"",
            "tool":"",
            "flutes":"2",
            "geometry":"Normal",
            "leadang":"90",
            "diameter":"0.0",
            "stickout":"0.0",
            "noseRad":"0.0",
            "sfm":"0.0",
            "chipload":"0.0",
            "generic":false,
            "xcomp":0,
            "zcomp":0,
            "xgeom":0,
            "zgeom":0,
            "serialno":"",
            "vendor":"",
            "product":"",
            "idNo":"",
            "insNo":"",
            "useMfgSFM":false,
            "useMfgIPT":false,
            "mfgSFM":0,
            "mfgIPT":0,
            "coating":"",
            "toolmaterial":""
         };
      }
      
      public function browseForImport(param1:Function) : void
      {
         this.importFcn = param1;
         this.cribFiles.doFileOpen(this.importTools,"Import");
      }
      
      protected function browseForExportAux(param1:String) : void
      {
         this.cribFiles.doFileSaveAs(this.exportTools,"Export",param1);
      }
      
      public function importTools(param1:File) : void
      {
      }
      
      public function exportTools(param1:File) : void
      {
      }
   }
}
