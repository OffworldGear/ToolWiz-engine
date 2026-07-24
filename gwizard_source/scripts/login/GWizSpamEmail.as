package login
{
   import mx.collections.ArrayCollection;
   
   public class GWizSpamEmail
   {
      
      private static var domainList:ArrayCollection = new ArrayCollection([{"domain":"10minutemail"},{"domain":"20minutemail"},{"domain":"33mail"},{"domain":"deadaddress"},{"domain":"e4ward"},{"domain":"easytrashmail"},{"domain":"emailsensei"},{"domain":"emailthe"},{"domain":"example"},{"domain":"gishpuppy"},{"domain":"guerrillamail"},{"domain":"inboxalias"},{"domain":"incognitomail"},{"domain":"jetable"},{"domain":"koszmail"},{"domain":"mailcatch"},{"domain":"mailexpire"},{"domain":"mailinator"},{"domain":"mailnesia"},{"domain":"mailnull"},{"domain":"meltmail"},{"domain":"mytrashmail"},{"domain":"noclickemail"},{"domain":"sharklaser"},{"domain":"sharklasers"},{"domain":"spamavert"},{"domain":"spambox"},{"domain":"spamex"},{"domain":"spamfree24"},{"domain":"spamgourmet"},{"domain":"spamspot"},{"domain":"tempemail"},{"domain":"tempomail"},{"domain":"trashmail"},{"domain":"yopmail"}]);
       
      
      public function GWizSpamEmail()
      {
         super();
      }
      
      public static function isSpamEmail(param1:String) : Boolean
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < domainList.length)
            {
               if(param1.indexOf(domainList.getItemAt(_loc2_).domain) >= 0)
               {
                  return true;
               }
               _loc2_++;
            }
         }
         return false;
      }
      
      public static function convertSpamEmail(param1:String, param2:String) : String
      {
         if(isSpamEmail(param1))
         {
            param1 = param2;
         }
         return param1;
      }
   }
}
