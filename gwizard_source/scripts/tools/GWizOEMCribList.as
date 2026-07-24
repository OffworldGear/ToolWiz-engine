package tools
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizStringUtils;
   import utils.GWizURLLoader;
   import utils.GWizUtils;
   
   public class GWizOEMCribList
   {
      
      private static const log:ILogger = Log.getLogger("GWizOEMCribList");
      
      private static const OEM_BASE_URL:String = "http://www.cnccookbook.com/img/GWizard/Downloads/OEM/";
      
      private static var didOEMCribDownload:Boolean = false;
      
      private static var downloadQueue:Array = [];
      
      private static var cribHash:Object = new Object();
      
      private static var firstOEMCrib:String = "";
      
      private static var laterGUID:String = "";
      
      public static var oemCribsDownloaded:Boolean = false;
       
      
      public function GWizOEMCribList()
      {
         super();
      }
      
      public static function getCribs() : void
      {
         var url:String = null;
         var loader:GWizURLLoader = null;
         var msg:String = null;
         var justASec:GWizJustASec = null;
         if(GWizSettings.gotPreferences)
         {
            if(!didOEMCribDownload && GWizAbstractPrefs.isOEM && GWizAbstractPrefs.oemStr != "")
            {
               url = OEM_BASE_URL + GWizAbstractPrefs.oemStr + ".csv";
               try
               {
                  loader = new GWizURLLoader();
                  loader.loadURL(url,catalogLoaded);
                  didOEMCribDownload = true;
               }
               catch(e:Error)
               {
                  msg = "Error downloading OEM cribs: " + e.message;
                  log.debug(msg);
                  GWizUtils.LogError(msg);
               }
            }
         }
         else
         {
            justASec = new GWizJustASec(getCribs);
         }
      }
      
      private static function catalogLoaded(param1:String, param2:String) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:GWizToolCribEntry = null;
         log.debug("Catalog downloaded.");
         var _loc3_:ArrayCollection = GWizCSVUtils.CSVToArrayCol(param1,",");
         if(_loc3_ && _loc3_.length > 0)
         {
            downloadQueue = [];
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = String(_loc3_[_loc4_].Name);
               param2 = OEM_BASE_URL + GWizAbstractPrefs.oemStr + "/" + _loc5_;
               if((_loc5_ = GWizStringUtils.left(_loc5_,_loc5_.length - ".csv".length)) == GWizStringUtils.left(GWizGarrOEMToolData.TOOLDATA_NAME,GWizGarrOEMToolData.TOOLDATA_NAME.length - ".csv".length))
               {
                  GWizGarrOEMToolData.getTechInfo(true);
               }
               else
               {
                  if(_loc4_ == 0)
                  {
                     firstOEMCrib = _loc5_;
                  }
                  cribHash[_loc5_] = true;
                  if(newCribNeeded(_loc5_,Number(_loc3_[_loc4_].version)))
                  {
                     (_loc6_ = new Object()).url = param2;
                     _loc6_.cribName = _loc5_;
                     _loc6_.version = Number(_loc3_[_loc4_].version);
                     downloadQueue.push(_loc6_);
                  }
                  else if(_loc4_ == 0)
                  {
                     _loc7_ = GWizCribList.getCribEntryAt(_loc5_,0);
                     setFSGUIDLater(_loc7_.guid);
                  }
               }
               _loc4_++;
            }
            downloadCrib();
         }
         else
         {
            GWizPopUpManager.Show("Can\'t download OEM tool data.","Error: Tool Data Unavailable",GWizPopUpManager.ERROR);
         }
      }
      
      private static function setFSGUIDLater(param1:String) : void
      {
         laterGUID = param1;
         var _loc2_:GWizJustASec = new GWizJustASec(setFSGUIDLaterAux,2);
      }
      
      private static function setFSGUIDLaterAux() : void
      {
         GWizSettings.FeedsSpeedsApp.Tool.setGuid(laterGUID);
      }
      
      private static function newCribNeeded(param1:String, param2:Number) : Boolean
      {
         var _loc3_:Number = NaN;
         if(param1 != "" && param2 > 0)
         {
            _loc3_ = GWizCribList.tableVersion(param1);
            return _loc3_ < param2;
         }
         return true;
      }
      
      private static function downloadCrib() : void
      {
         var queueObject:Object = null;
         var url:String = null;
         var loader:GWizURLLoader = null;
         var msg:String = null;
         var i:int = 0;
         var cribEntry:GWizToolCribEntry = null;
         var entry:Object = null;
         if(downloadQueue.length > 0)
         {
            queueObject = downloadQueue.pop();
            downloadQueue.push(queueObject);
            url = queueObject.url;
            log.debug("Adding crib \'" + url + "\'");
            try
            {
               loader = new GWizURLLoader();
               loader.loadURL(url,cribLoaded);
            }
            catch(e:Error)
            {
               msg = "Error downloading crib: " + e.message;
               log.debug(msg);
               GWizUtils.LogError(msg);
            }
         }
         else
         {
            i = 0;
            while(i < GWizCribList.cribList.length)
            {
               entry = GWizCribList.cribList.getItemAt(i);
               if(!cribHash.hasOwnProperty(entry.tabname))
               {
                  GWizCribList.delToolCrib(entry.tabname,true);
                  i = 0;
               }
               i++;
            }
            GWizSettings.cribData.fsCribList = GWizSettings.cribGeneration++;
            cribEntry = GWizToolCribData.ToolCrib.getCribEntryAt(i);
            GWizSettings.FeedsSpeedsApp.setToolFromGUID(cribEntry.guid);
            oemCribsDownloaded = true;
            log.debug("Finished downloading cribs.");
         }
      }
      
      private static function cribLoaded(param1:String, param2:String) : void
      {
         var _loc5_:String = null;
         var _loc6_:GWizToolCribEntry = null;
         var _loc3_:ArrayCollection = GWizCSVUtils.CSVToArrayCol(param1,",");
         var _loc4_:Object = downloadQueue.pop();
         if(_loc3_ && _loc3_.length > 0)
         {
            _loc5_ = _loc4_.cribName;
            GWizCribList.delToolCrib(_loc5_,true);
            GWizSettings.cribData.importCSVToolTable(_loc3_,_loc5_);
            if(_loc5_ == firstOEMCrib)
            {
               if(_loc6_ = GWizCribList.getCribEntryAt(_loc5_,0))
               {
                  setFSGUIDLater(_loc6_.guid);
               }
            }
            GWizCribList.setTableVersion(_loc5_,Number(_loc4_.version));
            log.debug("Crib downloaded successfully: \'" + _loc5_ + "\'" + ", version = " + Number(_loc4_.version));
            downloadCrib();
         }
         else
         {
            GWizPopUpManager.Show("Can\'t download OEM tool data for " + param2 + ".","Error: Tool Data Unavailable",GWizPopUpManager.ERROR);
            downloadCrib();
         }
      }
   }
}
