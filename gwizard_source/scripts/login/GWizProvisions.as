package login
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizProvisions
   {
      
      private static const log:ILogger = Log.getLogger("GWizProvisions");
      
      public static const GWCALC_TRIAL:String = "GWC";
      
      public static const GWCALC_SUBSC:String = "GWCS";
      
      public static const GWCALC_LITE_HP:String = "GWCL";
      
      public static const GWEDIT_TRIAL:String = "GWE";
      
      public static const GWEDIT_SUBSC:String = "GWES";
      
      public static const GWTHREADCALC_SUBSC:String = "GWTCS";
      
      public static const LOGO_CHANGE:String = "logo";
      
      public static const GW_PITA:String = "PITA";
      
      private static var provisioningInfo:String = "";
      
      private static var provisionAC:ArrayCollection = null;
      
      private static var useOldProvisions:Boolean = true;
      
      public static var provisionsLoaded:Boolean = false;
       
      
      public function GWizProvisions()
      {
         super();
      }
      
      public static function setProvisionsAsAC(param1:ArrayCollection) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(param1)
         {
            provisionAC = null;
            provisionAC = new ArrayCollection();
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = param1.getItemAt(_loc2_);
               _loc4_ = GWizUtils.clone(_loc3_);
               provisionAC.addItem(_loc4_);
               _loc2_++;
            }
            setAuxPrefs();
            provisionsLoaded = true;
         }
      }
      
      public static function setOtherGlobals(param1:Number, param2:Number, param3:String = "GWC") : void
      {
         if(param2 > 0)
         {
            GWizSettings.prefs.xlo = -param2 / 1000;
         }
         else if(param1 > 0)
         {
            GWizSettings.prefs.xlo = param1 / 1000;
         }
      }
      
      public static function getProvisions() : String
      {
         return provisioningInfo;
      }
      
      public static function extractProvision(param1:String) : String
      {
         return extractProvisionFromStr(param1,provisioningInfo);
      }
      
      public static function provisionStartDate(param1:String) : Date
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:Date = null;
         if(provisionAC)
         {
            _loc3_ = 0;
            while(_loc3_ < provisionAC.length)
            {
               if((_loc4_ = provisionAC.getItemAt(_loc3_)).name == param1 && _loc4_.hasOwnProperty("startDate"))
               {
                  if((_loc5_ = _loc4_.startDate) != "")
                  {
                     _loc2_ = new Date();
                     _loc2_.setTime(Date.parse(_loc5_));
                     break;
                  }
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public static function provisionEndDate(param1:String) : Date
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:Date = null;
         if(provisionAC)
         {
            _loc3_ = 0;
            while(_loc3_ < provisionAC.length)
            {
               if((_loc4_ = provisionAC.getItemAt(_loc3_)).name == param1 && _loc4_.hasOwnProperty("endDate"))
               {
                  if((_loc5_ = _loc4_.endDate) != "")
                  {
                     _loc2_ = new Date();
                     _loc2_.setTime(Date.parse(_loc5_));
                     break;
                  }
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public static function setProvisionEndDate(param1:String, param2:Date) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(provisionAC)
         {
            _loc3_ = 0;
            while(_loc3_ < provisionAC.length)
            {
               if((_loc4_ = provisionAC.getItemAt(_loc3_)).name == param1 && _loc4_.hasOwnProperty("endDate"))
               {
                  _loc4_.endDate = param2.toString();
               }
               _loc3_++;
            }
         }
      }
      
      public static function provisionDaysLeft(param1:String) : Number
      {
         var _loc5_:Date = null;
         var _loc2_:Date = new Date();
         var _loc3_:Date = provisionEndDate(param1);
         if(!_loc3_)
         {
            return 0;
         }
         var _loc4_:Number = _loc3_.time - _loc2_.time;
         if(GWizUtils.debug)
         {
            _loc5_ = provisionEndDate(param1);
         }
         _loc4_ /= GWizUtils.MILLI_PER_DAY;
         if(isNaN(_loc4_))
         {
            _loc4_ = 0;
         }
         return Math.max(_loc4_,0);
      }
      
      public static function provisionValue(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc2_:String = "";
         if(provisionAC)
         {
            _loc3_ = 0;
            while(_loc3_ < provisionAC.length)
            {
               _loc5_ = (_loc4_ = provisionAC.getItemAt(_loc3_)).name;
               if(_loc4_.name == param1 && _loc4_.hasOwnProperty("value"))
               {
                  if((_loc6_ = _loc4_.value) != "")
                  {
                     _loc2_ = _loc6_;
                     break;
                  }
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      private static function setAuxPrefs() : void
      {
         GWizAbstractPrefs.logoStr = provisionValue("logo");
         var _loc1_:String = GWizProvisions.provisionValue("GDTBasics");
         GWizAbstractPrefs.GDTBasics = _loc1_ != "";
         GWizAbstractPrefs.auxPrefsSet = true;
      }
      
      private static function extractProvisionFromStr(param1:String, param2:String) : String
      {
         var _loc3_:String = "";
         var _loc4_:String = "";
         var _loc5_:Number = 0;
         while(_loc5_ < param2.length)
         {
            while(_loc5_ < param2.length && param2.charAt(_loc5_) == " ")
            {
               _loc5_++;
            }
            while(_loc5_ < param2.length && param2.charAt(_loc5_) != " " && param2.charAt(_loc5_) != ":")
            {
               _loc4_ += param2.charAt(_loc5_);
               _loc5_++;
            }
            while(_loc5_ < param2.length && param2.charAt(_loc5_) == " ")
            {
               _loc5_++;
            }
            while(_loc5_ < param2.length && param2.charAt(_loc5_) == ":")
            {
               _loc5_++;
            }
            while(_loc5_ < param2.length && param2.charAt(_loc5_) == " ")
            {
               _loc5_++;
            }
            while(_loc5_ < param2.length && param2.charAt(_loc5_) != " " && param2.charAt(_loc5_) != ",")
            {
               _loc3_ += param2.charAt(_loc5_);
               _loc5_++;
            }
            if(_loc5_ < param2.length && param2.charAt(_loc5_) && param2.charAt(_loc5_) == ",")
            {
               _loc5_++;
            }
            if(_loc4_ == param1)
            {
               return _loc3_;
            }
            _loc4_ = "";
            _loc3_ = "";
         }
         return "";
      }
      
      public static function appSubscProvision() : String
      {
         if(GWizSettings.loginBar && GWizSettings.loginBar.appProvParm)
         {
            return GWizSettings.loginBar.appProvParm + "S";
         }
         return "";
      }
      
      public static function okayToUseApp(param1:String) : Boolean
      {
         var _loc2_:int = GWizProvisions.provisionDaysLeft(param1);
         _loc2_ = Math.max(_loc2_,GWizProvisions.provisionDaysLeft(param1 + "S"));
         _loc2_ = Math.max(_loc2_,GWizProvisions.provisionDaysLeft(param1 + "L"));
         return _loc2_ > 0 && !GWizCredentials.isPITA();
      }
   }
}
