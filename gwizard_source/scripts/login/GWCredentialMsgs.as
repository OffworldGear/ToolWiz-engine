package login
{
   import comps.GWizPopUpManager;
   import configinfo.GWizSettings;
   
   public class GWCredentialMsgs
   {
      
      public static var trialPopShown:Boolean = false;
      
      public static var popTipWin:Function = null;
       
      
      public function GWCredentialMsgs()
      {
         super();
      }
      
      public static function popTrial(param1:Boolean, param2:Boolean, param3:Number, param4:int, param5:Boolean) : Boolean
      {
         var _loc8_:GWizEvalPopUp = null;
         var _loc6_:Boolean = param2 && param3 >= 15;
         var _loc7_:Boolean = false;
         trialPopShown = trialPopShown || !param5;
         if(!_loc6_)
         {
            if(param3 <= 15 && GWizLoginBar.setLogins && GWizSettings.prefs.logins % 2 || param3 <= 7 || param3 < 0 || param2 && param3 <= 15 || !param1)
            {
               if(!trialPopShown)
               {
                  if(_loc8_ = GWizEvalPopUp(GWizPopUpManager.createPopUp(null,GWizEvalPopUp,true)))
                  {
                     _loc8_.setInTrial(param3,param4,param1,param2,GWizCredentials.LoginParm);
                  }
               }
            }
            else
            {
               _loc7_ = true;
            }
            trialPopShown = true;
         }
         else
         {
            _loc7_ = true;
         }
         if(_loc7_ && popTipWin != null)
         {
            popTipWin(false);
         }
         return param3 > 0;
      }
   }
}
