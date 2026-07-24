package login
{
   import configinfo.GWizAbstractPrefs;
   import configinfo.GWizSettings;
   import flash.net.NetworkInfo;
   import flash.net.NetworkInterface;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import session.CheckinService;
   import session.Session;
   import utils.GWizCrypto;
   import utils.GWizUtils;
   
   public class GWizSessionSvc
   {
      
      private static const log:ILogger = Log.getLogger("GWizSessionSvc");
      
      public static var gotCheckinResult:Function = null;
      
      public static var checkinComplete:Boolean = false;
      
      public static var checkinFailed:Boolean = false;
      
      public static var checkinPending:Boolean = false;
       
      
      private var serviceLogin:String = null;
      
      private var hashedLoginName:String = null;
      
      public const HTTP_REQUEST_ERROR:String = "HTTP request error";
      
      private var provisions:Object;
      
      public function GWizSessionSvc()
      {
         super();
         this.getMacAddr();
      }
      
      private function getMacAddr() : void
      {
         var _loc1_:Vector.<NetworkInterface> = null;
         var _loc2_:int = 0;
         if(NetworkInfo.isSupported)
         {
            _loc1_ = NetworkInfo.networkInfo.findInterfaces();
            GWizCredentials.macAddr = "";
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               GWizCredentials.macAddr += _loc1_[_loc2_].hardwareAddress.toString() + "|";
               _loc2_++;
            }
         }
         else
         {
            GWizCredentials.macAddr = "N/A";
         }
      }
      
      public function tryLogin(param1:String) : String
      {
         var _loc2_:String = GWizCrypto.hash(param1,Session.sessionPassword,Session.sessionStrlen);
         if(checkinPending)
         {
            return _loc2_;
         }
         checkinPending = true;
         var _loc3_:Function = this.checkinResult;
         if(false && GWizUtils.debug)
         {
            _loc3_ = this.checkinFail;
         }
         var _loc4_:CheckinService = new CheckinService(_loc3_,this.checkinFault);
         checkinComplete = false;
         checkinFailed = false;
         this.serviceLogin = param1;
         _loc4_.invoke(_loc2_,GWizSettings.loginBar.appNameParm,GWizSettings.appVersion,GWizCredentials.macAddr,0);
         return _loc2_;
      }
      
      private function checkinResult(param1:ResultEvent) : void
      {
         var _loc2_:int = param1.statusCode;
         var _loc3_:XML = param1.result as XML;
         checkinComplete = true;
         ++GWizSettings.connectionSuccess;
         this.processCheckinResult(checkinComplete,_loc3_.msg,_loc3_.status,_loc3_);
      }
      
      private function checkinFault(param1:FaultEvent) : void
      {
         var _loc2_:int = param1.statusCode;
         var _loc3_:String = param1.fault.faultString;
         log.debug("checkin error - " + _loc3_ + ", statusCode: " + _loc2_);
         log.debug("faultCode: " + param1.fault.faultCode);
         log.debug("faultDetail: " + param1.fault.faultDetail);
         log.debug("faultString: " + param1.fault.faultString);
         GWizUtils.LogError("checkin error - " + _loc3_);
         checkinComplete = false;
         checkinFailed = true;
         ++GWizSettings.connectionFails;
         this.processCheckinResult(checkinComplete,_loc3_,_loc2_,null);
      }
      
      private function checkinFail(param1:ResultEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = this.HTTP_REQUEST_ERROR;
         log.debug("checkin error - " + _loc3_);
         log.debug("event.statusCode = " + param1.statusCode);
         GWizUtils.LogError("checkin error - " + _loc3_);
         checkinComplete = false;
         checkinFailed = true;
         ++GWizSettings.connectionFails;
         this.processCheckinResult(checkinComplete,_loc3_,_loc2_,null);
      }
      
      private function processCheckinResult(param1:Boolean, param2:String, param3:int, param4:XML) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:XMLList = null;
         var _loc12_:XML = null;
         var _loc13_:int = 0;
         var _loc14_:Object = null;
         var _loc15_:int = 0;
         var _loc16_:Date = null;
         var _loc17_:Date = null;
         var _loc18_:Date = null;
         var _loc19_:Date = null;
         var _loc20_:Date = null;
         var _loc21_:Date = null;
         var _loc22_:Date = null;
         var _loc23_:Number = NaN;
         var _loc24_:Date = null;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Date = null;
         var _loc30_:Date = null;
         checkinPending = false;
         var _loc5_:ArrayCollection = null;
         var _loc6_:String = "";
         var _loc7_:String = "";
         var _loc8_:String = "";
         var _loc9_:String = "";
         if(param4)
         {
            _loc5_ = new ArrayCollection();
            if(param4 && param4.provisions)
            {
               _loc11_ = param4.provisions;
               for each(_loc12_ in _loc11_.provision)
               {
                  _loc5_.addItem(_loc12_);
                  log.debug("Provision: " + _loc12_);
               }
            }
            if(_loc5_ && _loc5_.length > 0)
            {
               _loc13_ = -1;
               _loc15_ = 0;
               while(_loc15_ < _loc5_.length)
               {
                  if((_loc14_ = _loc5_.getItemAt(_loc15_)).name != null)
                  {
                     if(_loc14_.name == GWizSettings.loginBar.appProvParm)
                     {
                        _loc21_ = new Date(String(_loc14_.startDate));
                        _loc22_ = new Date(String(_loc14_.endDate));
                        log.debug("trialStart = " + _loc21_);
                        log.debug("trialEnd = " + _loc22_);
                        if(GWizSettings.loginBar.appProvParm == "GWE")
                        {
                           _loc20_ = new Date("2/1/2013");
                           if(_loc21_.valueOf() < _loc20_.valueOf())
                           {
                              _loc21_ = _loc20_;
                              _loc22_ = GWizUtils.addDays(_loc21_,30);
                              _loc14_.startDate = GWizUtils.simpleDateStr(_loc21_);
                              _loc14_.endDate = GWizUtils.simpleDateStr(_loc22_);
                           }
                        }
                        _loc6_ = GWizUtils.simpleDateStr(_loc21_);
                        _loc7_ = GWizUtils.simpleDateStr(_loc22_);
                     }
                     else if(_loc14_.name == GWizProvisions.appSubscProvision())
                     {
                        _loc8_ = _loc14_.startDate;
                        _loc9_ = _loc14_.endDate;
                        _loc13_ = _loc15_;
                     }
                     if(_loc14_.name == GWizProvisions.GWTHREADCALC_SUBSC)
                     {
                        GWizAbstractPrefs.ThreadCalcEnabled = true;
                     }
                  }
                  _loc15_++;
               }
               _loc16_ = new Date(_loc6_);
               _loc17_ = new Date(_loc7_);
               _loc18_ = new Date(_loc8_);
               _loc19_ = new Date(_loc9_);
               if(_loc16_ <= _loc18_ && _loc17_ > _loc18_)
               {
                  _loc23_ = _loc17_.time - _loc18_.time;
                  _loc19_.time += _loc23_;
                  _loc9_ = String(_loc19_);
                  (_loc14_ = _loc5_.getItemAt(_loc13_)).endDate = _loc9_;
                  _loc5_.setItemAt(_loc14_,_loc13_);
               }
            }
         }
         if(gotCheckinResult != null)
         {
            param1 = false;
            if(param2 != this.HTTP_REQUEST_ERROR)
            {
               param2 = "Unregistered";
            }
            _loc25_ = (_loc24_ = new Date()).getTimezoneOffset() * 60 * 1000;
            _loc24_.setTime(_loc24_.getTime() + _loc25_ + 1 * 60 * 60 * 1000);
            _loc26_ = _loc24_.valueOf();
            _loc27_ = 0;
            _loc28_ = 0;
            if(_loc9_ && _loc9_ != "")
            {
               if((_loc27_ = (_loc29_ = new Date(_loc9_)).valueOf()) > _loc26_)
               {
                  param1 = true;
                  param2 = "Subscription still good";
               }
               else if(param2 != "HTTP request error")
               {
                  param2 = "Subscription lapsed, ended " + _loc29_;
               }
               param1 = true;
            }
            else if(_loc7_ && _loc7_ != "")
            {
               if((_loc28_ = (_loc30_ = new Date(_loc7_)).valueOf()) > _loc26_)
               {
                  param1 = true;
                  param2 = "Trial still good";
               }
               else if(param2 != "HTTP request error")
               {
                  param2 = "Trial lapsed, ended" + _loc30_;
               }
               _loc21_ = new Date(_loc6_);
               _loc10_ = (_loc10_ = _loc30_.getTime() - _loc21_.getTime()) / GWizUtils.MILLI_PER_DAY;
               param1 = true;
            }
            gotCheckinResult(this.serviceLogin,param1,param2,param3,_loc5_,Number((_loc28_ - _loc26_) / GWizUtils.MILLI_PER_DAY),Number((_loc27_ - _loc26_) / GWizUtils.MILLI_PER_DAY),_loc10_,GWizSettings.loginBar.appProvParm);
         }
      }
      
      private function checkinConflictFault(param1:FaultEvent) : void
      {
         var _loc2_:int = param1.statusCode;
         var _loc3_:String = param1.fault.faultString;
      }
   }
}
