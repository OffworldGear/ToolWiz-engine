package feedsspeeds
{
   import configinfo.GWizSettings;
   import machines.GWizMachSettings;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizFeedSpeedAPI
   {
      
      private static const log:ILogger = Log.getLogger("GWizFeedSpeedAPI");
       
      
      private const USE_UI:Boolean = true;
      
      public function GWizFeedSpeedAPI()
      {
         super();
      }
      
      private function convertGasPedal(param1:Number) : Number
      {
         return param1;
      }
      
      public function SetupUI(param1:String, param2:String, param3:String, param4:String, param5:Number, param6:int, param7:Number, param8:Number, param9:Number, param10:Boolean, param11:Boolean, param12:Boolean, param13:Boolean, param14:Number, param15:Boolean, param16:int = 0) : void
      {
         var _loc18_:Number = NaN;
         var _loc19_:Boolean = false;
         var _loc17_:Function = null;
         if(this.USE_UI)
         {
            if(!GWizSettings.FeedsSpeedsApp.didCC)
            {
               log.debug("FeedsSpeeds isn\'t ready!");
            }
            param14 = this.convertGasPedal(param14);
            if(GWizMachSettings.currMachine != param1)
            {
               GWizMachSettings.currMachine = param1;
            }
            if(param2 != "" && GWizSettings.FeedsSpeedsApp && GWizSettings.FeedsSpeedsApp.mms && GWizSettings.FeedsSpeedsApp.mms.MatChooser)
            {
               GWizSettings.FeedsSpeedsApp.mms.MatChooser.setMaterialToLabel(param2);
            }
            if(param3 != "")
            {
               GWizSettings.FeedsSpeedsApp.setToolFromGUID(param3);
               log.debug("GWizSettings.FeedsSpeedsApp.Tool.selectedLabel: " + GWizSettings.FeedsSpeedsApp.Tool.selectedLabel);
            }
            else
            {
               if(GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex > 0)
               {
                  GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex = 0;
                  log.debug("1: Set cribTbl to 0");
                  GWizSettings.FeedsSpeedsApp.onCribTblVC();
               }
               GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = param4;
               param5 = this.toolDiaFromTool(param5,param4);
               _loc18_ = param8 / param5;
               _loc19_ = false;
               if(_loc18_ > 7)
               {
                  _loc19_ = true;
               }
               if(param4.indexOf("Tapping") >= 0)
               {
                  if(_loc19_)
                  {
                     GWizSettings.FeedsSpeedsApp.td.setGeometry("Form Tap");
                  }
                  else
                  {
                     GWizSettings.FeedsSpeedsApp.td.setGeometry("");
                  }
               }
               else if(param4.indexOf("Thread Mill") < 0)
               {
                  if(param4.indexOf("Chamfer Endmill") >= 0)
                  {
                     param4 = param4.replace("Chamfer ","");
                     GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = param4;
                     GWizSettings.FeedsSpeedsApp.td.setGeometry("Chamfer / Countersink");
                  }
                  else if(param4.indexOf("Drill") >= 0)
                  {
                     if(_loc19_)
                     {
                        GWizSettings.FeedsSpeedsApp.td.setGeometry("Parabolic");
                     }
                     else
                     {
                        GWizSettings.FeedsSpeedsApp.td.setGeometry("");
                     }
                  }
                  else if(param4.indexOf("Threading") >= 0)
                  {
                     GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
                     GWizSettings.FeedsSpeedsApp.td.setGeometry("Threading");
                  }
                  else if(param4.indexOf("Parting") >= 0)
                  {
                     GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
                     GWizSettings.FeedsSpeedsApp.td.setGeometry("Grooving");
                  }
                  else if(param4.indexOf("Grooving") >= 0)
                  {
                     GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
                     GWizSettings.FeedsSpeedsApp.td.setGeometry("Parting");
                  }
                  else
                  {
                     GWizSettings.FeedsSpeedsApp.td._flutes.value = param6;
                     GWizSettings.FeedsSpeedsApp.td._stickout.setVal(param7);
                     GWizSettings.FeedsSpeedsApp.td.setGeometryViaBallnose(param13);
                     GWizSettings.FeedsSpeedsApp.td.setGeometryViaRougher(param12);
                     GWizSettings.FeedsSpeedsApp.td.recalc(false);
                  }
               }
               GWizSettings.FeedsSpeedsApp.td._toolDiameter.setVal(param5);
            }
            GWizSettings.FeedsSpeedsApp.cutDepth.setVal(param8);
            GWizSettings.FeedsSpeedsApp.cutWidth.setVal(param9);
            if(!isNaN(param9))
            {
               if(param4.indexOf("Thread Mill") >= 0 || param4.indexOf("Tapping") >= 0)
               {
                  GWizSettings.FeedsSpeedsApp.cutWidth.setVal(param9);
                  if(param4.indexOf("Thread Mill") >= 0)
                  {
                     GWizSettings.FeedsSpeedsApp.cutDepth.setVal(param9 * 10);
                  }
               }
            }
            GWizSettings.FeedsSpeedsApp.mfgSpecs.resetFamily();
            this.setCoolant(param15);
            if(param10)
            {
               GWizSettings.FeedsSpeedsApp.GasPedal.value = param14;
            }
            else
            {
               GWizSettings.FeedsSpeedsApp.GasPedal.value = GWizTortHare.GAS_PEDAL_FINISH;
            }
            if(param11)
            {
               GWizSettings.FeedsSpeedsApp.showHSMFeedsSpeeds.selected = true;
            }
            else
            {
               GWizSettings.FeedsSpeedsApp.showHSMFeedsSpeeds.selected = false;
            }
            GWizSettings.FeedsSpeedsApp.plungeModeIdx#1 = param16;
            GWizSettings.FeedsSpeedsApp.recalcAux();
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      private function setCoolant(param1:Boolean) : void
      {
         if(param1)
         {
            if(GWizSettings.FeedsSpeedsApp.TSC.enabled)
            {
               GWizSettings.FeedsSpeedsApp.TSC.selected = true;
            }
            else if(GWizSettings.FeedsSpeedsApp.PCN.enabled)
            {
               GWizSettings.FeedsSpeedsApp.PCN.selected = true;
            }
         }
         else
         {
            GWizSettings.FeedsSpeedsApp.TSC.selected = false;
            GWizSettings.FeedsSpeedsApp.PCN.selected = false;
         }
      }
      
      public function SetupUIGeometry(param1:String, param2:String, param3:String, param4:String, param5:Number, param6:int, param7:Number, param8:Number, param9:Number, param10:Boolean, param11:Boolean, param12:Boolean, param13:Boolean, param14:Number, param15:String, param16:Number, param17:Number, param18:int, param19:Boolean) : void
      {
         if(this.USE_UI)
         {
            this.SetupUI(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14,param19,param18);
            if(param3 == "" && param15 != "")
            {
               GWizSettings.FeedsSpeedsApp.td.toolParms.geometry = param15;
               GWizSettings.FeedsSpeedsApp.td.toolParms.cornerRadius = param16;
               GWizSettings.FeedsSpeedsApp.td.toolParms.leadAngle = param17;
            }
            GWizSettings.FeedsSpeedsApp.recalcAux();
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      public function SetupUIQuickly(param1:Number, param2:Number) : void
      {
         if(this.USE_UI)
         {
            GWizSettings.FeedsSpeedsApp.recalcWidthDepth(param2,param1);
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      public function SetupDrillUI(param1:String, param2:String, param3:String, param4:Boolean, param5:Number, param6:Number, param7:Number, param8:Boolean, param9:Number = NaN) : void
      {
         if(this.USE_UI)
         {
            param7 = this.convertGasPedal(param7);
            if(GWizMachSettings.currMachine != param1)
            {
               GWizMachSettings.currMachine = param1;
            }
            GWizSettings.FeedsSpeedsApp.mms.MatChooser.setMaterialToLabel(param2);
            GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex = 0;
            log.debug("2: Set cribTbl to 0");
            GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = param3;
            param5 = this.toolDiaFromTool(param5,param3);
            this.setCoolant(param8);
            if(param3.indexOf("Tapping") >= 0)
            {
               if(param4)
               {
                  GWizSettings.FeedsSpeedsApp.td.setGeometry("Form Tap");
               }
               else
               {
                  GWizSettings.FeedsSpeedsApp.td.setGeometry("");
               }
            }
            else if(param3.indexOf("Thread Mill") < 0)
            {
               if(param3.indexOf("Chamfer Endmill") >= 0)
               {
                  param3 = param3.replace("Chamfer ","");
                  GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = param3;
                  GWizSettings.FeedsSpeedsApp.td.setGeometry("Chamfer / Countersink");
               }
               else if(param4)
               {
                  GWizSettings.FeedsSpeedsApp.td.setGeometry("Parabolic");
               }
               else
               {
                  GWizSettings.FeedsSpeedsApp.td.setGeometry("");
               }
            }
            GWizSettings.FeedsSpeedsApp.td._toolDiameter.setVal(param5);
            GWizSettings.FeedsSpeedsApp.cutDepth.setVal(param6);
            if(!isNaN(param9))
            {
               if(param3.indexOf("Thread Mill") >= 0 || param3.indexOf("Tapping") >= 0)
               {
                  GWizSettings.FeedsSpeedsApp.cutWidth.setVal(param9);
                  if(param3.indexOf("Thread Mill") >= 0)
                  {
                     GWizSettings.FeedsSpeedsApp.cutDepth.setVal(param9 * 10);
                  }
               }
            }
            GWizSettings.FeedsSpeedsApp.GasPedal.value = param7;
            GWizSettings.FeedsSpeedsApp.recalcAux();
         }
         else
         {
            GWizUtils.assert(false);
         }
      }
      
      public function SetupTurningUI(param1:String, param2:String, param3:String, param4:Number, param5:Number, param6:Number, param7:Boolean = false) : Number
      {
         var _loc8_:Boolean = false;
         if(this.USE_UI)
         {
            param6 = this.convertGasPedal(param6);
            if(GWizMachSettings.currMachine != param1)
            {
               GWizMachSettings.currMachine = param1;
            }
            GWizSettings.FeedsSpeedsApp.mms.MatChooser.setMaterialToLabel(param2);
            GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex = 0;
            log.debug("3: Set cribTbl to 0");
            GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
            if(param3.indexOf("Threading") >= 0)
            {
               GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
               GWizSettings.FeedsSpeedsApp.td.setGeometry("Threading");
            }
            else if(param3.indexOf("Parting") >= 0)
            {
               GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
               GWizSettings.FeedsSpeedsApp.td.setGeometry("Parting");
            }
            else if(param3.indexOf("Grooving") >= 0)
            {
               GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
               GWizSettings.FeedsSpeedsApp.td.setGeometry("Grooving");
            }
            else
            {
               GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = "Turning: Carbide";
               GWizSettings.FeedsSpeedsApp.td.setGeometry("Turning");
            }
            GWizSettings.FeedsSpeedsApp.td._toolDiameter.setVal(param4);
            GWizSettings.FeedsSpeedsApp.td.recalc(false);
            GWizSettings.FeedsSpeedsApp.GasPedal.value = param6;
            if(param7)
            {
               _loc8_ = false;
               while(!_loc8_)
               {
                  GWizSettings.FeedsSpeedsApp.cutDepth.setVal(param5);
                  GWizSettings.FeedsSpeedsApp.recalcAux();
                  if(GWizSettings.FeedsSpeedsApp.api.getRPM() > 0 || param5 < 0.005)
                  {
                     _loc8_ = true;
                  }
                  else
                  {
                     param5 *= 0.8;
                  }
               }
            }
            else
            {
               GWizSettings.FeedsSpeedsApp.recalcAux();
            }
         }
         else
         {
            GWizUtils.assert(false);
         }
         return param5;
      }
      
      public function saveUI() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.machine = GWizSettings.FeedsSpeedsApp.mms.Machine.selectedName();
         _loc1_.material = GWizSettings.FeedsSpeedsApp.mms.MatChooser.Selection;
         _loc1_.crib = GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex;
         _loc1_.tool = GWizSettings.FeedsSpeedsApp.Tool.selectedLabel;
         _loc1_.toolDiameter = GWizSettings.FeedsSpeedsApp.td.toolParms.toolDiam;
         _loc1_.flutes = GWizSettings.FeedsSpeedsApp.td.toolParms.flutes;
         _loc1_.stickout = GWizSettings.FeedsSpeedsApp.td.toolParms.stickout;
         _loc1_.cutDepth = GWizSettings.FeedsSpeedsApp.cutDepth.getVal();
         _loc1_.cutWidth = GWizSettings.FeedsSpeedsApp.cutWidth.getVal();
         _loc1_.hsm = GWizSettings.FeedsSpeedsApp.useHSM();
         _loc1_.geometry = GWizSettings.FeedsSpeedsApp.td.geometryLabel();
         _loc1_.GasPedal = GWizSettings.FeedsSpeedsApp.GasPedal.value;
         return _loc1_;
      }
      
      public function restoreUI(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         if(GWizMachSettings.currMachine != param1.machine)
         {
            GWizMachSettings.currMachine = param1.machine;
         }
         GWizSettings.FeedsSpeedsApp.mms.MatChooser.setMaterialToLabel(param1.material);
         if(param1.crib == 0)
         {
            log.debug("4: Set cribTbl to 0");
         }
         GWizSettings.FeedsSpeedsApp.cribTbl.selectedIndex = param1.crib;
         GWizSettings.FeedsSpeedsApp.onCribTblVC();
         GWizSettings.FeedsSpeedsApp.Tool.selectedLabel = param1.tool;
         GWizSettings.FeedsSpeedsApp.td._toolDiameter.setVal(param1.toolDiameter);
         GWizSettings.FeedsSpeedsApp.td._flutes.value = param1.flutes;
         GWizSettings.FeedsSpeedsApp.td._stickout.setVal(param1.stickout);
         GWizSettings.FeedsSpeedsApp.cutDepth.setVal(param1.cutDepth);
         GWizSettings.FeedsSpeedsApp.cutWidth.setVal(param1.cutWidth);
         GWizSettings.FeedsSpeedsApp.showHSMFeedsSpeeds.selected = param1.hsm == "true";
         GWizSettings.FeedsSpeedsApp.td.setGeometry(param1.geometry);
         GWizSettings.FeedsSpeedsApp.GasPedal.value = param1.GasPedal;
      }
      
      public function getMRR() : Number
      {
         if(this.USE_UI)
         {
            return GWizUtils.roundHundredths(GWizSettings.FeedsSpeedsApp.fsm.mrr);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getRPM() : Number
      {
         if(this.USE_UI)
         {
            return Math.floor(GWizSettings.FeedsSpeedsApp.fsm.rpm.value);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getSFM() : Number
      {
         if(this.USE_UI)
         {
            return Math.floor(GWizSettings.FeedsSpeedsApp.fsm.sfm.value);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getFeed() : Number
      {
         if(this.USE_UI)
         {
            return GWizUtils.roundHundredths(GWizSettings.FeedsSpeedsApp.fsm.ipm.value);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getIPR() : Number
      {
         if(this.USE_UI)
         {
            return GWizUtils.roundTenths(GWizSettings.FeedsSpeedsApp.fsm.ipr);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getHP() : Number
      {
         if(this.USE_UI)
         {
            return GWizUtils.roundHundredths(GWizSettings.FeedsSpeedsApp.fsm.hp);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getHPLimit() : Number
      {
         if(this.USE_UI)
         {
            return GWizUtils.roundHundredths(GWizSettings.FeedsSpeedsApp.fsm.hpLimit.value);
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getEffDia() : Number
      {
         if(this.USE_UI)
         {
            return GWizSettings.FeedsSpeedsApp.fsm.effDiam;
         }
         GWizUtils.assert(false);
         return NaN;
      }
      
      public function getEntryFeedrate() : Number
      {
         return GWizSettings.FeedsSpeedsApp.PlungeRate.getVal();
      }
      
      public function deflectErr(param1:Boolean) : Boolean
      {
         if(this.USE_UI)
         {
            return GWizSettings.FeedsSpeedsApp.deflectErr(param1);
         }
         GWizUtils.assert(false);
         return true;
      }
      
      public function cuttingErr() : String
      {
         if(this.USE_UI)
         {
            return GWizSettings.FeedsSpeedsApp.cuttingError;
         }
         GWizUtils.assert(false);
         return "NYI Error";
      }
      
      public function toolDiaFromTool(param1:Number, param2:String) : Number
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(isNaN(param1))
         {
            _loc3_ = "";
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               _loc6_ = _loc3_.charAt(_loc4_);
               if("0" <= _loc6_ <= "9")
               {
                  _loc3_ += _loc6_;
               }
               else if(_loc6_ == "." || _loc6_ == "/")
               {
                  _loc3_ += _loc6_;
               }
               else if(_loc6_ != " ")
               {
                  break;
               }
               _loc4_++;
            }
            if((_loc5_ = _loc3_.indexOf("/")) > 0)
            {
               _loc7_ = _loc3_.substr(0,_loc5_);
               _loc3_ = _loc3_.substr(_loc5_ + 1);
               param1 = Number(_loc7_) / Number(_loc3_);
            }
            else
            {
               param1 = Number(_loc3_);
            }
         }
         return param1;
      }
   }
}
