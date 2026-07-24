package auth
{
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class AuthTest
   {
      
      private static const log:ILogger = Log.getLogger("GetAuth");
      
      private static var orderTest:ArrayCollection = new ArrayCollection([{
         "Email":"gjohnson@transenterix.com",
         "GWCSStart":"1/12/2018",
         "GWCSEnd":"5/15/3017",
         "GWCSTime":1000,
         "GWESStart":"1/12/2018",
         "GWESEnd":"5/15/3017",
         "GWESTime":1000,
         "OEM":""
      }]);
       
      
      public function AuthTest()
      {
         super();
         doTests();
      }
      
      public static function doTests() : void
      {
         if(GWizUtils.debug)
         {
            checkinTest();
            postOrdersTest();
         }
      }
      
      private static function checkinTest() : void
      {
         GetAuth.invoke("gjohnson@transenterix.com");
      }
      
      private static function postOrdersTest() : void
      {
         PostOrders.invoke("gjohnson@transenterix.com",orderTest);
      }
   }
}
