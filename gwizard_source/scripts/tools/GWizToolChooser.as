package tools
{
   import cadcamwiz.GWizCCWGenericWizard;
   import cadcamwiz.GWizCCWMillOptions;
   import cadcamwiz.GWizCadCam;
   import comps.GWizNumStepOvr;
   import configinfo.GWizConfigData;
   import configinfo.GWizSettings;
   import login.GWizLoginBar;
   import machines.GWizMachSettings;
   import material.GWizMaterialsDB;
   import utils.GWizUtils;
   
   public class GWizToolChooser
   {
      
      public static var toolDesignation:String = "";
      
      public static var drillDFM:String = "";
      
      public static var toolStr:String = "Carbide Endmill";
      
      public static var useBallnose:Boolean = false;
      
      public static var corncob:Boolean;
      
      public static var indexable:Boolean;
      
      public static var facemill:Boolean;
       
      
      public function GWizToolChooser()
      {
         super();
      }
      
      public static function calcFlutes(param1:String = "") : int
      {
         var _loc2_:int = 4;
         if(param1 == "")
         {
            param1 = GWizSettings.FeedsSpeedsApp.currMaterial();
         }
         if(GWizMaterialsDB.isNonFerrous(param1))
         {
            _loc2_ = 3;
         }
         return _loc2_;
      }
      
      public static function calcToolDia(param1:String, param2:Number, param3:int, param4:Number, param5:Number, param6:GWizNumStepOvr, param7:Boolean, param8:Boolean, param9:Boolean) : Number
      {
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:int = 0;
         var _loc16_:Object = null;
         toolDesignation = "";
         GWizCCWMillOptions.cribTool = -1;
         if(!param7)
         {
            param2 = GWizCCWMillOptions.maxToolDiameter(param3,param8,param9) / 2;
         }
         var _loc10_:Number;
         if((_loc10_ = 2 * param2) > GWizCCWMillOptions.maxToolDiameter(param3,param8,param9))
         {
            _loc10_ = GWizCCWMillOptions.maxToolDiameter(param3,param8,param9);
         }
         if(GWizSettings.loginBar.appNameParm == GWizLoginBar.GW_ESTIMATOR_NAMEPARM)
         {
            _loc10_ = Math.min(_loc10_,param4);
            _loc10_ = Math.min(_loc10_,param5);
         }
         var _loc11_:Number;
         if((_loc11_ = GWizSettings.FeedsSpeedsApp.api.getHPLimit()) <= 0.16)
         {
            _loc10_ = Math.min(_loc10_,0.125);
         }
         else if(_loc11_ <= 0.64)
         {
            _loc10_ = Math.min(_loc10_,0.25);
         }
         else if(_loc11_ <= 1.44)
         {
            _loc10_ = Math.min(_loc10_,0.375);
         }
         else if(_loc11_ <= 2.55)
         {
            _loc10_ = Math.min(_loc10_,0.5);
         }
         _loc10_ = fixMinRPMProblems(param1,_loc10_);
         if(param6 && param6.isOverridden())
         {
            _loc10_ = param6.getVal();
         }
         var _loc12_:Number = 0;
         if(GWizCCWMillOptions.useCribForSolidEndmills() && param6 && !param6.isOverridden())
         {
            if(param3 <= 0)
            {
               param3 = GWizToolChooser.calcFlutes();
            }
            if(GWizUtils.debug)
            {
               GWizUtils.assert(param3 > 0);
            }
            if((_loc12_ = GWizCCWMillOptions.maxEndmillDiaInCCWCribList(_loc10_,param3,param8,param9)) <= 0 || GWizToolCribArray.cribToolGUID == "")
            {
               GWizCCWGenericWizard.Instance.addDFMHint("Couldn\'t find a suitable endmill in Tool Crib.");
               _loc12_ = 0;
            }
         }
         if(_loc12_ <= 0)
         {
            _loc13_ = GWizCadCam.CADCAMWiz.ccwOptions.ImpSizes.selected;
            _loc14_ = GWizCadCam.CADCAMWiz.ccwOptions.MMSizes.selected;
            _loc15_ = 0;
            while(_loc15_ < GWizConfigData.DrillData.length)
            {
               if((_loc16_ = GWizConfigData.DrillData.getItemAt(_loc15_)).inch <= _loc10_)
               {
                  if(_loc13_ && _loc16_.eminch > 0)
                  {
                     _loc12_ = _loc16_.inch;
                     toolDesignation = _loc16_.designation;
                  }
                  if(_loc14_ && _loc16_.emmm > 0)
                  {
                     _loc12_ = _loc16_.inch;
                     toolDesignation = _loc16_.designation;
                  }
               }
               _loc15_++;
            }
            if(param6 && param6.isOverridden())
            {
               _loc12_ = param6.getVal();
            }
         }
         _loc10_ = Math.max(0.001,_loc10_);
         if(!isNaN(_loc12_))
         {
            _loc10_ = _loc12_;
         }
         else
         {
            if(isNaN(_loc12_))
            {
               GWizCCWGenericWizard.Instance.addDFMHint("Requires a non-standard tool diameter.");
            }
            toolDesignation = toolDiaToStr(_loc10_);
         }
         return _loc10_;
      }
      
      private static function drillSize(param1:Number) : String
      {
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         drillDFM = "";
         var _loc2_:Object = findDrillEntry(param1);
         if(_loc2_)
         {
            _loc3_ = _loc2_.inch;
            _loc4_ = _loc2_.designation;
         }
         if(!isNaN(_loc3_) && Math.abs(param1 - _loc3_) <= 0.001)
         {
            param1 = _loc3_;
         }
         else
         {
            _loc4_ = toolDiaToStr(param1);
            drillDFM = "Hole is a non-standard diameter and will require custom tooling.\n";
         }
         return _loc4_;
      }
      
      public static function findDrillEntry(param1:Number) : Object
      {
         var _loc4_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         while(_loc3_ < GWizConfigData.DrillData.length)
         {
            if((_loc4_ = GWizConfigData.DrillData.getItemAt(_loc3_)).inch > param1)
            {
               return _loc2_;
            }
            _loc2_ = _loc4_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function toolDiaToStr(param1:Number) : String
      {
         var _loc2_:* = String(GWizUtils.roundThousandths(param1)) + "\"";
         if(GWizUtils.Units != GWizUtils.INCHES_UNITS)
         {
            _loc2_ = GWizUtils.roundBigTenths2Str(param1,true) + "mm";
         }
         return _loc2_;
      }
      
      public static function getDrillName(param1:String, param2:Number, param3:Boolean) : String
      {
         var _loc4_:String = "";
         if(param3)
         {
            _loc4_ = "Parabolic Flute ";
         }
         return drillSize(param2) + " " + _loc4_ + param1;
      }
      
      private static function fixMinRPMProblems(param1:String, param2:Number) : Number
      {
         var _loc3_:Number = GWizSettings.FeedsSpeedsApp.fsm.lookupBaseSFMAux(GWizCadCam.CADCAMWiz.MatChooser.Selection,param1,false);
         var _loc4_:Number = 12 * _loc3_ / (Math.PI * param2);
         var _loc5_:Object;
         var _loc6_:Number = (_loc5_ = GWizMachSettings.lookupMachine(GWizMachSettings.currMachine)).rpmMinLimit - 1;
         if(_loc4_ < _loc6_)
         {
            param2 = GWizSettings.FeedsSpeedsApp.fsm.minRPMDiaAdjust(param2,_loc4_,_loc6_) * 0.8;
         }
         return param2;
      }
      
      public static function getToolStr() : String
      {
         return toolStr;
      }
      
      public static function setToolStr(param1:Boolean, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean, param7:Boolean) : void
      {
         useBallnose = param7;
         if(param2)
         {
            toolStr = "HSS Endmill";
         }
         else if(param3)
         {
            toolStr = "HP HSS Endmill";
         }
         else if(param4)
         {
            toolStr = "HP Carbide Endmill";
         }
         else if(param5)
         {
            toolStr = "TiAlN Carbide Endmill";
         }
         else
         {
            toolStr = "Carbide Endmill";
         }
         if(param6)
         {
            toolStr = "Indexable End Or Face Mill";
         }
         if(param7)
         {
            toolStr = toolStr.replace("Endmill","Ballnose");
         }
      }
      
      public static function getToolDesc(param1:Boolean, param2:Boolean, param3:Number, param4:int) : String
      {
         var _loc9_:GWizToolCribEntry = null;
         var _loc10_:String = null;
         var _loc5_:String = "";
         var _loc6_:String = GWizToolChooser.toolDesignation;
         if(param1 && (param2 || indexable) || facemill || _loc6_ == "")
         {
            _loc6_ = toolDiaToStr(param3);
         }
         var _loc7_:String = "";
         if(param1 && corncob)
         {
            _loc7_ = "Corncob ";
         }
         var _loc8_:* = "";
         if(!indexable)
         {
            _loc8_ = param4 + " flute ";
         }
         _loc5_ = _loc6_ + " " + _loc8_ + _loc7_ + toolStr;
         if(GWizCCWMillOptions.cribTool != -1 && !indexable && !facemill)
         {
            if(_loc9_ = GWizCCWMillOptions.toolCribEntry(GWizCCWMillOptions.cribTool))
            {
               if((_loc10_ = _loc9_.description) == "")
               {
                  _loc6_ = GWizToolChooser.toolDiaToStr(_loc9_.diameter);
                  _loc8_ = _loc9_.flutes + " flute ";
                  _loc10_ = _loc6_ + " " + _loc8_ + _loc9_.tool + _loc9_.geometry;
               }
               _loc5_ = _loc10_ + " from crib " + GWizCCWMillOptions.SolidCribName;
            }
         }
         return _loc5_;
      }
      
      public static function setDrillStr(param1:Boolean, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean) : void
      {
         if(param1)
         {
            toolStr = "HSS Twist Drill";
         }
         else if(param2)
         {
            toolStr = "HP HSS Twist Drill";
         }
         else if(param3)
         {
            toolStr = "Cobalt Twist Drill";
         }
         else if(param4)
         {
            toolStr = "Carbide Twist Drill";
         }
         else if(param5)
         {
            toolStr = "HP Carbide Twist Drill";
         }
         else if(param6)
         {
            toolStr = "Indexable Drill";
         }
      }
      
      public static function getSpotDrillName(param1:Number, param2:Boolean = false) : String
      {
         var _loc4_:Number = NaN;
         var _loc3_:* = "";
         if(GWizUtils.Units == GWizUtils.INCHES_UNITS)
         {
            _loc4_ = 0.25;
            while(_loc4_ <= 1.75 && _loc4_ <= param1)
            {
               _loc4_ += 0.25;
            }
            _loc3_ = _loc4_ + "\" ";
         }
         else if(param1 < 10 / 25.4)
         {
            _loc3_ = "10mm ";
         }
         else if(param1 < 12 / 25.4)
         {
            _loc3_ = "12mm ";
         }
         else if(param1 < 14 / 25.4)
         {
            _loc3_ = "14mm ";
         }
         else if(param1 < 16 / 25.4)
         {
            _loc3_ = "16mm ";
         }
         else if(param1 < 18 / 25.4)
         {
            _loc3_ = "18mm ";
         }
         else if(param1 < 20 / 25.4)
         {
            _loc3_ = "20mm ";
         }
         else
         {
            _loc3_ = "25mm ";
         }
         return _loc3_ + (!!param2 ? "Carbide " : "HSS ") + "Spot Drill";
      }
   }
}
