package bubbletip
{
   import configinfo.GWizSettings;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import mx.collections.ArrayCollection;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizCSVUtils;
   import utils.GWizCallChain;
   import utils.GWizUtils;
   
   public class GWizAbstractBubbleMsgs
   {
      
      private static const log:ILogger = Log.getLogger("GWizAbstractBubbleMsgs");
      
      public static var showAll:Boolean = false;
       
      
      public var bubbleEnabledCC:GWizCallChain;
      
      private var bubbleMsgs:ArrayCollection;
      
      private var defaultBubbleMsgs:ArrayCollection;
      
      private var stateLoaded:Boolean = false;
      
      public var _resetBtnLocation:String;
      
      public function GWizAbstractBubbleMsgs(param1:String)
      {
         this.bubbleEnabledCC = new GWizCallChain();
         this.bubbleMsgs = new ArrayCollection();
         this.defaultBubbleMsgs = new ArrayCollection([{
            "id":"StartWizard",
            "text":"",
            "popupOK":true,
            "finished":false,
            "wakeUp1":"LoginButton",
            "wakeUp2":"RegisterButton",
            "wakeUp3":"GettingStarted"
         },{
            "id":"LoginButton",
            "text":"If you haven\'t already, click the Login button. It\'ll pop up a box\n" + "where you enter the email you registered or subscribed with.\n\n" + "If you see your email name instead of \'Howdy Guest\' to the left\n" + "you\'re already logged in.\n\n" + "When  you exit, don\'t logoff. It\'s easier just to let G-Wizard\n" + "remember that info and log you back in automatically.\n\n" + "If you need to change your login, that\'d be a good time to click\n" + "the Logout.",
            "popupOK":false,
            "finished":false,
            "wakeUp1":"",
            "wakeUp2":"",
            "wakeUp3":""
         },{
            "id":"RegisterButton",
            "text":"If you haven\'t registered or subscribed, you can use\n" + "the Register button to register for a free trial right now.\n\n" + "You\'ll receive a confirmation link back in email after you\n" + "register that you need to click to activate the free trial.\n\n",
            "popupOK":false,
            "finished":false,
            "wakeUp1":"VsnLabel",
            "wakeUp2":"",
            "wakeUp3":""
         },{
            "id":"GettingStarted",
            "text":"The Getting Started button pops up your web browser and\n" + "sends it to the Getting Started page for your software.\n" + "This page has lots of great info for beginners.\n\n" + "If it doesn\'t pop up, you probably have a popup block installed.\n" + "You can find the Getting Start page by clicking the Help menu at\n" + "the top of any CNCCookbook web page.\n",
            "popupOK":false,
            "finished":false,
            "wakeUp1":"",
            "wakeUp2":"",
            "wakeUp3":""
         },{
            "id":"VsnLabel",
            "text":"This area tells what version you\'re running.  If there\n" + "is a newer version available, the button to the right will help\n" + "install it.  If you get no popup, this is due to a popup blocker.\n" + "You\'ll have to go to the CNCCookbook web site and click the Help\n" + "menu.  The install links are at the top of the Help page.\n\n" + "If your version is up to date, the button on the right lets you.\n" + "give us your feedback\n",
            "popupOK":false,
            "finished":false,
            "wakeUp1":"",
            "wakeUp2":"",
            "wakeUp3":""
         }]);
         super();
         this.setupDefaultMsgs(param1);
      }
      
      public static function showAllBubbles() : void
      {
         showAll = !showAll;
         GWizSettings.bubbleMsgs.bubbleEnabledCC.callChain("");
      }
      
      public function addBubbleMsg(param1:Object, param2:String) : Boolean
      {
         var _loc3_:Object = null;
         GWizUtils.assert(this.bubbleMsgs != null);
         this.bubbleMsgs.addItem(param1);
         if(param2 && param2.length > 0)
         {
            _loc3_ = this.getBubbleMsg(param2);
            GWizUtils.assert(_loc3_);
            if(_loc3_)
            {
               if(_loc3_.wakeUp1.length <= 0)
               {
                  _loc3_.wakeUp1 = param1.id;
               }
               else if(_loc3_.wakeUp2.length <= 0)
               {
                  _loc3_.wakeUp2 = param1.id;
               }
               else
               {
                  if(_loc3_.wakeUp3.length > 0)
                  {
                     return false;
                  }
                  _loc3_.wakeUp3 = param1.id;
               }
            }
         }
         return true;
      }
      
      public function allowBubbleTips() : Boolean
      {
         return GWizUtils.debug;
      }
      
      public function popupOKFor(param1:String) : Boolean
      {
         this.loadBubbleState();
         var _loc2_:Object = this.getBubbleMsg(param1);
         return showAll || _loc2_ && _loc2_.popupOK && !_loc2_.finished;
      }
      
      public function bubbleMsg(param1:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:Object = this.getBubbleMsg(param1);
         if(_loc3_ && _loc3_.text)
         {
            _loc2_ = _loc3_.text;
         }
         return _loc2_;
      }
      
      public function finishedBubble(param1:String, param2:Boolean = true, param3:Boolean = true) : void
      {
         var _loc4_:Object;
         if(_loc4_ = this.getBubbleMsg(param1))
         {
            _loc4_.finished = param2;
            if(param2)
            {
               this.wakeUp(_loc4_.wakeUp1);
               this.wakeUp(_loc4_.wakeUp2);
               this.wakeUp(_loc4_.wakeUp3);
            }
            this.bubbleEnabledCC.callChain(param1);
            if(param3)
            {
               this.saveBubbleState();
            }
         }
         if(GWizAbstractBubbleMsgs.showAll)
         {
            GWizAbstractBubbleMsgs.showAll = false;
            this.bubbleEnabledCC.callChain("");
         }
      }
      
      public function popupOKBubble(param1:String, param2:Boolean = true, param3:Boolean = true) : void
      {
         var _loc4_:Object;
         if(_loc4_ = this.getBubbleMsg(param1))
         {
            _loc4_.popupOK = param2;
            this.bubbleEnabledCC.callChain(param1);
            if(param3)
            {
               this.saveBubbleState();
            }
         }
      }
      
      public function bubbleFinished(param1:String) : Boolean
      {
         var _loc2_:Object = this.getBubbleMsg(param1);
         if(_loc2_)
         {
            return _loc2_.finished && !showAll;
         }
         return !showAll;
      }
      
      private function wakeUp(param1:String) : void
      {
         var _loc2_:Object = null;
         if(param1 && param1 != "")
         {
            _loc2_ = this.getBubbleMsg(param1);
            _loc2_.popupOK = true;
            _loc2_.finished = false;
            this.bubbleEnabledCC.callChain(param1);
         }
      }
      
      private function getBubbleMsg(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.bubbleMsgs.length)
         {
            _loc3_ = this.bubbleMsgs.getItemAt(_loc2_);
            if(_loc3_.id == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function saveBubbleState() : void
      {
         var entry:Object = null;
         var saver:Object = null;
         var contents:String = null;
         var file:File = null;
         var stream:FileStream = null;
         var fileAC:ArrayCollection = new ArrayCollection();
         var i:int = 0;
         while(i < this.bubbleMsgs.length)
         {
            entry = this.bubbleMsgs.getItemAt(i);
            saver = new Object();
            saver.id = entry.id;
            saver.finished = entry.finished;
            saver.popupOK = entry.popupOK;
            fileAC.addItem(saver);
            i++;
         }
         if(fileAC.length > 0)
         {
            contents = GWizCSVUtils.arrayColToCSV(fileAC,",",["id","finished","popupOK"]);
            try
            {
               file = GWizSettings.getPrefsFile("BubbleMsgs.csv");
               stream = new FileStream();
               stream.open(file,FileMode.WRITE);
               stream.writeUTFBytes(contents);
               stream.close();
            }
            catch(e:Error)
            {
               GWizUtils.assert(false);
            }
         }
      }
      
      private function loadBubbleState() : void
      {
         var file:File = null;
         var bubbleState:ArrayCollection = null;
         var i:int = 0;
         var saver:Object = null;
         if(!this.stateLoaded)
         {
            this.stateLoaded = true;
            try
            {
               file = GWizSettings.getPrefsFile("BubbleMsgs.csv");
               if(file && file.exists)
               {
                  bubbleState = GWizCSVUtils.loadCSVFile(file,false);
                  if(bubbleState)
                  {
                     i = 0;
                     while(i < bubbleState.length)
                     {
                        saver = bubbleState.getItemAt(i);
                        this.finishedBubble(saver.id,String(saver.finished).toUpperCase() == "TRUE",false);
                        this.popupOKBubble(saver.id,String(saver.popupOK).toUpperCase() == "TRUE",false);
                        i++;
                     }
                  }
                  else
                  {
                     log.debug("bubbleState = null after loading");
                     GWizUtils.assert(false);
                  }
               }
               else
               {
                  log.debug("No bubbleState file exists");
               }
            }
            catch(e:Error)
            {
               log.debug("Error loading bubbleState = " + e.message);
               GWizUtils.assert(false);
            }
         }
      }
      
      public function resetBubbleTips() : void
      {
         GWizSettings.startWizardRun = false;
         this.setupDefaultMsgs(this._resetBtnLocation);
         this.saveBubbleState();
      }
      
      public function setupDefaultMsgs(param1:String) : void
      {
         var _loc4_:Object = null;
         this._resetBtnLocation = param1;
         this.bubbleMsgs.removeAll();
         var _loc2_:int = 0;
         while(_loc2_ < this.defaultBubbleMsgs.length)
         {
            _loc4_ = GWizUtils.clone(this.defaultBubbleMsgs.getItemAt(_loc2_));
            this.bubbleMsgs.addItem(_loc4_);
            _loc2_++;
         }
         var _loc3_:Object = this.bubbleMsgs.getItemAt(0);
         _loc3_.text = "This is a Bubble Tip. It tells you more about whatever Bubble\n" + "you clicked on. Once you\'ve finished a tip, it won\'t show up again unless you reset the Bubble Tips.\n\n" + "There is a reset button located in \n\n" + param1 + "\n\n" + "You finish a bubble by click the Got It! button, close button, or really anywhere on the popup.\n\n";
      }
   }
}
