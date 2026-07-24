package tools
{
   import comps.GWizPopUpManager;
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.filesystem.File;
   import material.GWizMaterialsDB;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizStringUtils;
   import utils.GWizUtils;
   
   public class GWizGarrOEMToolData
   {
      
      private static const log:ILogger = Log.getLogger("GWizGarrOEMToolData");
      
      private static var toolDataFile:File;
      
      private static var toolData:ArrayCollection = null;
      
      private static var downloadDataAux:Boolean = false;
      
      private static var getTechInfoAuxRetries:int = 0;
      
      public static const TOOLDATA_NAME:String = "TechInfo.csv";
      
      private static var fieldNames:Array = ["Series","ISO","MaterialType","Material","HRC","EnglishMetric","Midpoint","MidSFM","MidIPT","VcLow","VcHigh","Dia0625/1.5L","Dia0625/1.5H","Dia125/3L","Dia125/3H","Dia1875/5L","Dia1875/5H","Dia250/6L","Dia250/6H","Dia3125/8L","Dia3125/8H","Dia375L/10","Dia375/10H","Dia500/12L","Dia500/12H","Dia625/16L","Dia625/16H","Dia750/20L","Dia750/20H","Dia100/25L","Dia100/25H"];
      
      private static var sfmDataMissing:Boolean = true;
      
      private static var fieldDecoder:ArrayCollection = new ArrayCollection([{
         "fieldName":"Dia0625/1.5L",
         "dia":0.0625,
         "LHField":"1.5L"
      },{
         "fieldName":"Dia0625/1.5H",
         "dia":0.0625,
         "LHField":"1.5H"
      },{
         "fieldName":"Dia125/3L",
         "dia":0.125,
         "LHField":"3L"
      },{
         "fieldName":"Dia125/3H",
         "dia":0.125,
         "LHField":"3H"
      },{
         "fieldName":"Dia1875/5L",
         "dia":0.1875,
         "LHField":"5L"
      },{
         "fieldName":"Dia1875/5H",
         "dia":0.1875,
         "LHField":"5H"
      },{
         "fieldName":"Dia250/6L",
         "dia":0.25,
         "LHField":"6L"
      },{
         "fieldName":"Dia250/6H",
         "dia":0.25,
         "LHField":"6H"
      },{
         "fieldName":"Dia3125/8L",
         "dia":0.3125,
         "LHField":"8L"
      },{
         "fieldName":"Dia3125/8H",
         "dia":0.3125,
         "LHField":"8H"
      },{
         "fieldName":"Dia375L/10",
         "dia":0.375,
         "LHField":"10L"
      },{
         "fieldName":"Dia375/10H",
         "dia":0.375,
         "LHField":"10H"
      },{
         "fieldName":"Dia500/12L",
         "dia":0.5,
         "LHField":"12L"
      },{
         "fieldName":"Dia500/12H",
         "dia":0.5,
         "LHField":"12H"
      },{
         "fieldName":"Dia625/16L",
         "dia":0.625,
         "LHField":"16L"
      },{
         "fieldName":"Dia625/16H",
         "dia":0.625,
         "LHField":"16H"
      },{
         "fieldName":"Dia750/20L",
         "dia":0.75,
         "LHField":"20L"
      },{
         "fieldName":"Dia750/20H",
         "dia":0.75,
         "LHField":"20H"
      },{
         "fieldName":"Dia100/25L",
         "dia":1,
         "LHField":"25L"
      },{
         "fieldName":"Dia100/25H",
         "dia":1,
         "LHField":"25H"
      }]);
      
      private static var findOEMRecordErrors:int = 0;
       
      
      public function GWizGarrOEMToolData()
      {
         super();
         getTechInfo();
      }
      
      public static function getTechInfo(param1:Boolean = false) : void
      {
         var _loc2_:GWizJustASec = null;
         downloadDataAux = param1;
         if(GWizSettings.gotPreferences && GWizAbstractPrefs.isOEM)
         {
            getTechInfoAux();
         }
         else if(GWizAbstractPrefs.isOEM)
         {
            _loc2_ = new GWizJustASec(getTechInfoAux);
         }
      }
      
      private static function getTechInfoAux() : void
      {
         var _loc2_:GWizJustASec = null;
         ++getTechInfoAuxRetries;
         var _loc1_:Boolean = downloadDataAux;
         if(GWizSettings.gotPreferences && GWizAbstractPrefs.isOEM)
         {
            toolDataFile = getToolDataFile(false);
            if(_loc1_ || !toolDataFile.exists)
            {
               GWizCSVUtils.downloadCSV("http://cnccookbook.com/img/GWizard/Downloads/OEM/garrtool/TechInfo.csv",gotTechInfo);
            }
            else if(!toolData || toolData.length <= 0)
            {
               toolData = GWizCSVUtils.loadCSVFile(toolDataFile);
               if(toolData.length <= 0)
               {
                  GWizCSVUtils.downloadCSV("http://cnccookbook.com/img/GWizard/Downloads/OEM/garrtool/TechInfo.csv",gotTechInfo);
               }
            }
         }
         else if(GWizAbstractPrefs.isOEM)
         {
            _loc2_ = new GWizJustASec(getTechInfoAux);
            if(getTechInfoAuxRetries == 50)
            {
               GWizPopUpManager.Show("Error downloading Tech Info: Error #2.","Error: Tech Info",GWizPopUpManager.ERROR);
            }
         }
      }
      
      private static function getToolDataFile(param1:Boolean = false) : File
      {
         return GWizAbstractPrefs.getShareablePrefsFile(TOOLDATA_NAME,param1);
      }
      
      private static function adjustISO(param1:String) : String
      {
         switch(param1)
         {
            case "K3":
               param1 = "K2";
               break;
            case "M2":
               param1 = "M2.1";
               break;
            case "M3":
               param1 = "M3.1";
               break;
            case "M4":
               param1 = "M4.1";
               break;
            case "N3":
               param1 = "N3.1";
               break;
            case "N4":
               param1 = "N4.1";
               break;
            case "P2.1":
            case "P2.2":
            case "P2.3":
               param1 = "P1";
               break;
            case "P3.2":
               param1 = "P3.3";
               break;
            case "P4":
               param1 = "P4.1";
               break;
            case "S1":
               param1 = "S1.1";
               break;
            case "S4":
               param1 = "S4.1";
               break;
            case "S5":
               param1 = "S5.1";
         }
         return param1;
      }
      
      private static function gotTechInfo(param1:ArrayCollection) : void
      {
         var _loc3_:Object = null;
         if(!param1 || param1.length <= 0)
         {
            GWizPopUpManager.Show("Error downloading Tech Info.","Error: Tech Info",GWizPopUpManager.ERROR);
         }
         toolData = new ArrayCollection();
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1.getItemAt(_loc2_);
            if(_loc3_.EnglishMetric == "E")
            {
               _loc3_.Series = GWizStringUtils.zapWhiteSpace(_loc3_.Series);
               _loc3_.ISO = GWizStringUtils.zapWhiteSpace(_loc3_.ISO);
               toolData.addItem(_loc3_);
            }
            _loc2_++;
         }
         if(toolData.length <= 0)
         {
            if(findOEMRecordErrors <= 0)
            {
               GWizPopUpManager.Show("Error downloading Tech Info: Error #5.","Error: Tech Info",GWizPopUpManager.ERROR);
               ++findOEMRecordErrors;
            }
         }
         else
         {
            GWizCSVUtils.saveCSVFile(toolDataFile,toolData,fieldNames);
         }
      }
      
      public static function lookupSFM(param1:String, param2:Number, param3:String, param4:Number, param5:Number, param6:Number) : Number
      {
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(param1 && param1 != "" && param3 && param3 != "")
         {
            if((_loc7_ = findOEMRecord(param1,param2,param3)) && _loc7_.hasOwnProperty("VcHigh"))
            {
               _loc8_ = Number(_loc7_.VcHigh) - Number(_loc7_.VcLow);
               _loc9_ = 0.5;
               if(_loc7_.hasOwnProperty("MidSFM"))
               {
                  _loc9_ = _loc7_.MidSFM;
                  if(GWizAbstractPrefs.isGarr() && param5 >= 1 && param6 >= 1)
                  {
                     _loc9_ = 0.25;
                  }
               }
               param4 = _loc10_ = Number(_loc7_.VcLow) + _loc8_ * _loc9_;
            }
            else if(!sfmDataMissing)
            {
               log.debug("Series missing in OEM tool data: " + param3);
               GWizPopUpManager.Show("SFM data missing for GARR TOOL data: " + param3,"Error: Tech Info",GWizPopUpManager.ERROR);
               sfmDataMissing = true;
            }
         }
         return param4;
      }
      
      public static function lookupIPT(param1:String, param2:Number, param3:String, param4:Number, param5:Number, param6:Number, param7:Number, param8:Boolean = true) : Number
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc9_:Object;
         if(_loc9_ = findOEMRecord(param1,param2,param3))
         {
            param6 /= param4;
            param7 /= param4;
            _loc12_ = 0;
            while(_loc12_ < fieldDecoder.length - 1)
            {
               _loc13_ = fieldDecoder.getItemAt(_loc12_);
               _loc14_ = fieldDecoder.getItemAt(_loc12_ + 1);
               _loc15_ = _loc9_[_loc13_.fieldName];
               if(param4 <= _loc13_.dia)
               {
                  if(isNaN(_loc15_) || _loc15_ <= 0)
                  {
                     _loc15_ = _loc10_;
                  }
                  _loc16_ = _loc9_[_loc14_.fieldName];
                  if(isNaN(_loc16_) || _loc16_ <= 0)
                  {
                     _loc16_ = _loc11_;
                  }
                  if(!isNaN(_loc15_))
                  {
                     param5 = _loc15_;
                     if(param8 && !isNaN(_loc16_))
                     {
                        _loc17_ = Number(_loc16_) - Number(_loc15_);
                        _loc18_ = 0.5;
                        if(_loc9_.hasOwnProperty("Midpoint"))
                        {
                           _loc18_ = _loc9_.Midpoint;
                        }
                        if(_loc9_.hasOwnProperty("MidIPT"))
                        {
                           _loc18_ = _loc9_.MidIPT;
                        }
                        _loc19_ = Number(_loc15_) + _loc17_ * _loc18_;
                        if(!isNaN(_loc19_))
                        {
                           _loc19_ = Number(_loc15_) + _loc17_ * _loc18_;
                           if(GWizAbstractPrefs.isGarr())
                           {
                              if(param6 >= 1 && param7 >= 0.7)
                              {
                                 _loc19_ = GWizUtils.interpolate(0.7,_loc19_,param7,1,_loc15_);
                              }
                              if(param7 >= 0.7)
                              {
                                 _loc19_ = GWizUtils.interpolate(0.7,_loc19_,param6,1,_loc15_);
                              }
                           }
                           param5 = _loc19_;
                        }
                     }
                  }
                  return param5;
               }
               _loc10_ = _loc15_;
               _loc11_ = _loc16_;
               _loc12_++;
            }
         }
         return param5;
      }
      
      private static function flattenSeries(param1:String) : String
      {
         if(GWizAbstractPrefs.isOEM)
         {
            if(GWizAbstractPrefs.oemStr == GWizAbstractPrefs.GARR_OEM_STR)
            {
               param1 = param1.replace("-","");
               switch(param1)
               {
                  case "1160":
                  case "1180":
                  case "1250H":
                  case "1280H":
                  case "1280KD":
                  case "1280KH":
                     break;
                  case "142B":
                  case "142R":
                  case "143R":
                     param1 = "142M";
                     break;
                  case "1550H":
                  case "1580H":
                  case "1580HD":
                  case "1580KD":
                  case "1580KH":
                  case "1850H":
                  case "1880KH":
                  case "4100":
                  case "H45":
                  case "TMR":
                  case "TMS":
                     break;
                  case "V4B":
                  case "V4R":
                  case "V4S":
                     param1 = "V4";
                     break;
                  case "VX7B":
                  case "VX7R":
                  case "VX7S":
                     param1 = "VX7";
               }
            }
         }
         return param1;
      }
      
      public static function materialToOEMISOCode(param1:String) : String
      {
         var _loc2_:String = GWizMaterialsDB.familyToISOCode(param1);
         return adjustISO(_loc2_);
      }
      
      private static function isHard(param1:Number) : Boolean
      {
         var _loc2_:Number = 371;
         return param1 > _loc2_;
      }
      
      private static function adjustISOForHardness(param1:String, param2:Number) : String
      {
         switch(param1)
         {
            case "M2.1":
               if(isHard(param2))
               {
                  param1 = "M2.2";
               }
               break;
            case "M2.2":
               if(!isHard(param2))
               {
                  param1 = "M2.1";
               }
               break;
            case "M3.1":
               if(isHard(param2))
               {
                  param1 = "M3.2";
               }
               break;
            case "M3.2":
               if(!isHard(param2))
               {
                  param1 = "M3.1";
               }
               break;
            case "M4.1":
               if(isHard(param2))
               {
                  param1 = "M4.2";
               }
               break;
            case "M4.2":
               if(!isHard(param2))
               {
                  param1 = "M4.1";
               }
               break;
            case "P3.1":
               if(isHard(param2))
               {
                  param1 = "P3.2";
               }
               break;
            case "P3.2":
               if(!isHard(param2))
               {
                  param1 = "P3.1";
               }
               break;
            case "P3.3":
               if(!isHard(param2))
               {
                  param1 = "P3.1";
               }
               break;
            case "P4.1":
               if(isHard(param2))
               {
                  param1 = "P4.2";
               }
               break;
            case "P4.2":
               if(!isHard(param2))
               {
                  param1 = "P4.1";
               }
               break;
            case "S2.1":
               if(isHard(param2))
               {
                  param1 = "S2.2";
               }
               break;
            case "S2.2":
               if(!isHard(param2))
               {
                  param1 = "S2.1";
               }
               break;
            case "S3.1":
               if(isHard(param2))
               {
                  param1 = "S3.2";
               }
               break;
            case "S3.2":
               if(!isHard(param2))
               {
                  param1 = "S3.1";
               }
               break;
            case "S4.1":
               if(isHard(param2))
               {
                  param1 = "S4.2";
               }
               break;
            case "S4.2":
               if(!isHard(param2))
               {
                  param1 = "S4.1";
               }
               break;
            case "S5.1":
               if(isHard(param2))
               {
                  param1 = "S5.2";
               }
               break;
            case "S5.2":
               if(!isHard(param2))
               {
                  param1 = "S5.1";
               }
         }
         return param1;
      }
      
      private static function findOEMRecord(param1:String, param2:Number, param3:String) : Object
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         if(toolData && param3 && param3 != "")
         {
            if(toolData.length <= 0 && findOEMRecordErrors <= 0)
            {
               GWizPopUpManager.Show("Error downloading Tech Info: Error #3.","Error: Tech Info",GWizPopUpManager.ERROR);
               ++findOEMRecordErrors;
            }
            param3 = flattenSeries(param3);
            _loc5_ = materialToOEMISOCode(param1);
            _loc5_ = adjustISOForHardness(_loc5_,param2);
            _loc6_ = 0;
            while(_loc6_ < toolData.length)
            {
               _loc4_ = toolData.getItemAt(_loc6_);
               if(GWizUtils.debug && param1 == "" && flattenSeries(_loc4_.Series) == param3)
               {
                  return _loc4_;
               }
               if(_loc4_.ISO == _loc5_ && flattenSeries(_loc4_.Series) == param3)
               {
                  if(!isHard(param2) && String(_loc4_.HRC).indexOf("L") >= 0)
                  {
                     return _loc4_;
                  }
                  if(isHard(param2) && String(_loc4_.HRC).indexOf("G") >= 0)
                  {
                     return _loc4_;
                  }
               }
               _loc6_++;
            }
            if(GWizUtils.debug)
            {
               log.debug("Missing OEM data for series " + param3);
            }
         }
         return null;
      }
   }
}
