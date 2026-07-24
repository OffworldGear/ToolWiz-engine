package tools
{
   import comps.GWizFileBrowser;
   import comps.GWizPopUpManager;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import machines.GWizMachSettings;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GATracker;
   import utils.GWizCSVUtils;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizCribF360TSV extends GWizCribFileFormat
   {
      
      private static const log:ILogger = Log.getLogger("GWizCribF360TSV");
       
      
      private var importNotes:String = "";
      
      public function GWizCribF360TSV()
      {
         super();
         cribFiles = new GWizFileBrowser("F360Cribs","F360","*.tsv");
      }
      
      override public function importTools(param1:File) : void
      {
         var ac:ArrayCollection = null;
         var f:File = param1;
         try
         {
            ac = GWizCSVUtils.loadCSVFile(f,true,true,null,"",GWizStringUtils.TAB,".tsv",this.prepFunction);
            this.importF360TSVToolTable(ac,f.name);
         }
         catch(e:Error)
         {
            log.debug("Error loading F360 tool library: " + e.errorID + ", msg = " + e.message);
         }
      }
      
      private function prepFunction(param1:String) : String
      {
         if(param1.indexOf("version") >= 0)
         {
            param1 = param1.substr("version".length);
            param1 = param1.substr(param1.indexOf("type"));
         }
         return param1;
      }
      
      private function adjUnits(param1:Number, param2:String) : Number
      {
         if(param2 == GWizToolCribEntry.MM_UNIT)
         {
            param1 /= 25.4;
         }
         return param1;
      }
      
      private function parseF360ToolInfo(param1:GWizToolCribEntry, param2:String, param3:String) : GWizToolCribEntry
      {
         var _loc4_:String = "Normal";
         if(!param3)
         {
            param3 = "carbide";
         }
         param3 = param3.toLowerCase();
         switch(param3)
         {
            case "hss":
            case "unspecified":
               param3 = "HSS";
               break;
            case "carbide":
            case "ti coated":
               param3 = "Carbide";
               break;
            default:
               log.debug("Unknown F360 tool type: \'" + param3 + "\'");
               this.importNotes += "Unsupported F360 tool material: \'" + param3 + "\'. Defaulted to HSS.";
               param3 = "HSS";
         }
         param2 = param2.toLowerCase();
         switch(param2)
         {
            case "drill":
               param2 = "Twist Drill";
               break;
            case "flat end mill":
            case "bull nose end mill":
            case "tapered mill":
               param2 = "Endmill";
               break;
            case "ball end mill":
               param2 = "Endmill";
               _loc4_ = "Ballnose";
               break;
            case "chamfer mill":
            case "counter sink":
               param2 = "Endmill";
               _loc4_ = "Chamfer / Countersink";
               break;
            case "dovetail mill":
               param2 = "Endmill";
               _loc4_ = "Dovetail";
               break;
            case "lollipop mill":
               param2 = "Endmill";
               _loc4_ = "Lollipop";
               break;
            case "radius mill":
               param2 = "Endmill";
               _loc4_ = "Corner Round";
               break;
            case "center drill":
               param2 = "Center Drill";
               break;
            case "spot drill":
               param2 = "Spot Drill";
               break;
            case "reamer":
               param2 = "Reamer";
               break;
            case "face mill":
               param2 = "Indexable End Or Face Mill";
               break;
            case "slot mill":
               param2 = "Saws & Woodruff Cutters";
               break;
            case "tap right hand":
            case "tap left hand":
               param2 = "Tapping";
               break;
            case "thread mill":
               param2 = "Thread Mill";
               break;
            case "turning general":
               param2 = "Turning";
               break;
            case "boring bar":
               param2 = "Boring Bar";
               _loc4_ = "Boring Bar";
               break;
            case "turning boring":
               param2 = "Boring Bar";
               _loc4_ = "Boring Bar";
               break;
            case "turning threading":
               param2 = "Threading";
               _loc4_ = "Threading";
               break;
            case "turning grooving":
               param2 = "Grooving";
               _loc4_ = "Grooving";
               break;
            case "probe":
               param2 = "Probe";
               break;
            case "holder":
               param2 = "Holder";
               break;
            default:
               log.debug("Unknown F360 tool type: \'" + param2 + "\'");
               this.importNotes += "Unsupported F360 tool type: \'" + param2 + "\'. ";
               param2 = "Endmill";
         }
         param2 = param3 + " " + param2;
         param1.toolmaterial = param3;
         param1.tool = param2;
         param1.geometry = _loc4_;
         return param1;
      }
      
      private function importF360TSVToolTable(param1:ArrayCollection, param2:String) : void
      {
         var i:int = 0;
         var f360:Object = null;
         var gwc:GWizToolCribEntry = null;
         var units:String = null;
         var hypotenuse:Number = NaN;
         var radChange:Number = NaN;
         var rpm:Number = NaN;
         var ipm:Number = NaN;
         var ipt:Number = NaN;
         var ac:ArrayCollection = param1;
         var fname:String = param2;
         fname = fname.substr(0,fname.length - ".tsv".length);
         if(fname == "")
         {
            return;
         }
         var keyInit:int = 0;
         var gwcTable:ArrayCollection = new ArrayCollection();
         var errCount:int = 0;
         i = 0;
         while(i < ac.length)
         {
            try
            {
               if(GWizUtils.debug)
               {
                  log.debug("Importing F360 tool library entry #" + i);
                  if(i == 11)
                  {
                     log.debug("gotcha!");
                  }
               }
               f360 = ac.getItemAt(i);
               this.importNotes = "";
               gwc = new GWizToolCribEntry();
               gwc.machname = GWizMachSettings.currMachine;
               gwc.tabname = fname;
               gwc.units = f360.unit;
               units = gwc.units;
               gwc.units = "inches";
               gwc = this.parseF360ToolInfo(gwc,f360.type,f360["material-name"]);
               gwc.description = f360.description;
               gwc.comment = f360.comment;
               gwc.vendor = f360.manufacturer;
               gwc.product = f360["product-id"];
               gwc.productLink = f360["product-link"];
               gwc.slot = f360.number;
               gwc.diameter = this.adjUnits(f360.diameter,units);
               gwc.tipLength = this.adjUnits(f360["tip-length"],units);
               gwc.noseRad = this.adjUnits(f360["corner-radius"],units);
               gwc.cutLength = this.adjUnits(f360["flute-length"],units);
               gwc.leadang = f360["taper-angle"];
               if(0 < gwc.leadang && gwc.leadang < 90 && gwc.geometry.indexOf("Chamfer") < 0)
               {
                  hypotenuse = gwc.cutLength / Math.cos(GWizUtils.radians(gwc.leadang));
                  radChange = hypotenuse * Math.sin(GWizUtils.radians(gwc.leadang));
                  gwc.diameter += 2 * radChange;
               }
               gwc.taperAngle2 = f360["taper-angle2"];
               gwc.shoulderLength = this.adjUnits(f360["shoulder-length"],units);
               gwc.shankSize = this.adjUnits(f360["shaft-diameter"],units);
               gwc.stickout = this.adjUnits(f360["body-length"],units);
               gwc.overallLength = this.adjUnits(f360["overall-length"],units);
               gwc.flutes = f360["number-of-flutes"];
               if(false && GWizUtils.debug)
               {
                  rpm = Number(f360["spindle-rpm"]);
                  if(rpm > 0)
                  {
                     gwc.mfgSFM = rpm / (Math.PI * gwc.diameter);
                     gwc.mfgSFM /= 12;
                     gwc.useMfgSFM = true;
                  }
                  ipm = this.adjUnits(Number(f360["cutting-feedrate"]),units);
                  if(ipm > 0)
                  {
                     ipt = ipm / (rpm * gwc.flutes);
                     gwc.mfgIPT = ipt;
                     gwc.useMfgIPT = true;
                  }
               }
               gwc.tipDiameter = this.adjUnits(f360["tip-diameter"],units);
               gwc.threadPitch = this.adjUnits(f360["thread-pitch"],units);
               gwc.coolantSupport = f360["coolant-support"];
               gwc.coolantMode = f360["coolant-mode"];
               gwc.clockwise = f360.clockwise == "yes";
               if(this.importNotes != "")
               {
                  gwc.comment = gwc.comment + "IMPORT: " + this.importNotes;
                  errCount++;
               }
               gwcTable.addItem(gwc);
            }
            catch(e:Error)
            {
               log.debug("Error: Could not import Tool #" + i);
               GWizPopUpManager.Show("Error: Could not import Tool #" + i,"F360 Import Finished",GWizPopUpManager.WARN);
            }
            i++;
         }
         if(this.importFcn != null)
         {
            this.importFcn(gwcTable,fname + ".tsv");
         }
         var msg:String = ac.length + " F360 tools imported. ";
         if(errCount > 0)
         {
            msg += errCount + " errors. Search \'IMPORT\' to find problem tools.";
         }
         else
         {
            msg += "No errors.";
         }
         GWizPopUpManager.Show(msg,"F360 Import Finished",GWizPopUpManager.WARN);
         GATracker.logPageView("F360ToolImport",ac.length + "Tools" + errCount + "Errors");
      }
      
      public function browseForExport() : void
      {
         browseForExportAux("Tools.dat");
      }
      
      override public function exportTools(param1:File) : void
      {
         var f:File = param1;
         var stream:FileStream = new FileStream();
         try
         {
            stream.open(f,FileMode.WRITE);
            GWizUtils.assert(false);
            stream.close();
         }
         catch(e:Error)
         {
            GWizPopUpManager.Show("Error exporting file: " + e.message,"Error: Export Failed",GWizPopUpManager.ERROR);
         }
      }
   }
}
