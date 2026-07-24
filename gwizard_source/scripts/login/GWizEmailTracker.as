package login
{
   import configinfo.GWizSettings;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import mx.collections.ArrayCollection;
   import utils.GWizCSVUtils;
   import utils.GWizJustASec;
   import utils.GWizUtils;
   
   public class GWizEmailTracker
   {
      
      private static var loginEmails:ArrayCollection = null;
      
      private static var emailsFile:File;
      
      private static const EMAILS_NAME:String = "CADCAMWizardData.csv";
      
      private static var fieldList:Array = ["dat","info"];
      
      private static var trackingLoginEmail:Boolean = false;
       
      
      public function GWizEmailTracker()
      {
         super();
      }
      
      public static function loadEmails() : void
      {
         var _loc1_:FileStream = null;
         var _loc2_:String = null;
         emailsFile = GWizSettings.getPrefsFile(EMAILS_NAME);
         try
         {
            _loc1_ = new FileStream();
            if(emailsFile.exists)
            {
               _loc1_.open(emailsFile,FileMode.READ);
               _loc2_ = _loc1_.readUTFBytes(_loc1_.bytesAvailable);
               loginEmails = GWizCSVUtils.CSVToArrayCol(_loc2_,",");
            }
            _loc1_.close();
         }
         catch(e:Error)
         {
         }
         if(!loginEmails)
         {
            loginEmails = new ArrayCollection();
         }
      }
      
      public static function trackLoginEmail() : void
      {
         var _loc1_:GWizJustASec = null;
         if(!trackingLoginEmail)
         {
            trackingLoginEmail = true;
            _loc1_ = new GWizJustASec(trackLoginEmailAux);
         }
      }
      
      public static function trackLoginEmailAux() : void
      {
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc1_:String = encode(GWizLoginBar.LoginParm);
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < loginEmails.length)
         {
            if((_loc5_ = loginEmails.getItemAt(_loc3_)).hasOwnProperty("dat"))
            {
               if((_loc6_ = _loc5_.dat) == _loc1_)
               {
                  return;
               }
            }
            _loc3_++;
         }
         var _loc4_:Object;
         (_loc4_ = new Object()).dat = _loc1_;
         _loc4_.info = encode(GWizCredentials.macAddr);
         loginEmails.addItem(_loc4_);
         if(emailsFile)
         {
            GWizCSVUtils.saveCSVFile(emailsFile,loginEmails,fieldList);
         }
         trackingLoginEmail = false;
      }
      
      public static function encode(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc2_:String = "";
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ += String.fromCharCode(param1.charCodeAt(_loc3_) + 1);
            _loc3_++;
         }
         if(GWizUtils.debug)
         {
            GWizUtils.assert(decode(_loc2_) == param1);
         }
         return _loc2_;
      }
      
      public static function decode(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc2_:String = "";
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ += String.fromCharCode(param1.charCodeAt(_loc3_) - 1);
            _loc3_++;
         }
         return _loc2_;
      }
   }
}
