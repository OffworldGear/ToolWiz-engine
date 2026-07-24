package login
{
   import com.NTPTime.ntpTimeUtility;
   import flash.events.Event;
   
   public class GWizSysTimeCheck
   {
      
      public static const NOT_TESTED:int = 0;
      
      public static const TIME_OK:int = 1;
      
      public static const TIME_BAD:int = 2;
      
      public static const TIME_ERROR:int = 3;
      
      public static var timeCheckResult:int = NOT_TESTED;
       
      
      private var ntpTime:ntpTimeUtility;
      
      public function GWizSysTimeCheck()
      {
         super();
         this.createNtpTimeUtility();
         this.ntpTime.initiateUDPTimeRequest();
      }
      
      private function createNtpTimeUtility() : void
      {
         if(this.ntpTime == null)
         {
            this.ntpTime = new ntpTimeUtility();
            this.ntpTime.addEventListener(ntpTimeUtility.NTP_TIME_RECIEVED,this.handleNTPTime,false,0,true);
            this.ntpTime.addEventListener(ntpTimeUtility.NTP_TIMEOUT,this.handleNtpTimeError,false,0,true);
         }
         else
         {
            this.destroyNtpTimeUtility(true);
         }
      }
      
      private function destroyNtpTimeUtility(param1:Boolean = false) : void
      {
         if(this.ntpTime != null)
         {
            this.ntpTime.removeEventListener(ntpTimeUtility.NTP_TIME_RECIEVED,this.handleNTPTime);
            this.ntpTime.removeEventListener(ntpTimeUtility.NTP_TIMEOUT,this.handleNtpTimeError);
            this.ntpTime.destroyInternals();
            this.ntpTime = null;
            if(param1 == true)
            {
               this.createNtpTimeUtility();
            }
         }
      }
      
      private function handleNTPTime(param1:Event) : void
      {
         var _loc2_:Date = new Date();
         var _loc3_:int = 1000 * 60 * 60 * 24;
         if(Math.abs(_loc2_.valueOf() - this.ntpTime.latestNTPTime.valueOf()) <= _loc3_)
         {
            timeCheckResult = TIME_OK;
         }
         else
         {
            timeCheckResult = TIME_BAD;
         }
         this.destroyNtpTimeUtility();
      }
      
      private function handleNtpTimeError(param1:Event) : void
      {
         timeCheckResult = TIME_ERROR;
         this.destroyNtpTimeUtility();
      }
   }
}
