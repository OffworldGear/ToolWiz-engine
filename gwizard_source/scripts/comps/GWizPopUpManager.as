package comps
{
   import bubbletip.GWizLoginWizard;
   import configinfo.GWizSettings;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.describeType;
   import mx.binding.utils.BindingUtils;
   import mx.controls.Spacer;
   import mx.core.IVisualElement;
   import mx.events.CloseEvent;
   import mx.managers.PopUpManager;
   import rtwp.ResizableTitleWindow;
   import rtwp.ResizableTitleWindowSkin;
   import spark.components.Button;
   import spark.components.HGroup;
   import spark.components.TitleWindow;
   import spark.layouts.VerticalLayout;
   import utils.ColorPalette;
   
   public class GWizPopUpManager extends PopUpManager
   {
      
      public static const ID_OK:String = "okBtn";
      
      public static const ID_CANCEL:String = "cancelBtn";
      
      public static const YES:uint = 1;
      
      public static const NO:uint = 2;
      
      public static const OK:uint = 4;
      
      public static const CANCEL:uint = 8;
      
      public static const WARN:uint = 16;
      
      public static const ERROR:uint = 32;
      
      private static var alertsShowing:Array = [];
      
      private static const HANG_ON_TITLE:String = "Hang On...";
      
      private static var hangOnCloser:Function = null;
      
      private static var openPopupList:Array = [];
       
      
      public function GWizPopUpManager()
      {
         super();
      }
      
      public static function createPopUp(param1:DisplayObject, param2:Class, param3:Boolean = false, param4:Boolean = false) : Object
      {
         var _loc5_:IVisualElement = null;
         if(findOpen(param2) == -1 && (!GWizLoginWizard.loginWizardActive || param4))
         {
            if(!param1)
            {
               param1 = GWizSettings.docWindow;
            }
            _loc5_ = new param2();
            createPopUpAux(param1,param2,param3,_loc5_);
         }
         return _loc5_;
      }
      
      public static function createPopUpFromContent(param1:DisplayObject, param2:Class, param3:IVisualElement, param4:Boolean = false, param5:Boolean = false) : void
      {
         if(findOpen(param2) == -1 && (!GWizLoginWizard.loginWizardActive || param5))
         {
            if(!param1)
            {
               param1 = GWizSettings.docWindow;
            }
            createPopUpAux(param1,param2,param4,param3);
         }
      }
      
      private static function createPopUpAux(param1:DisplayObject, param2:Class, param3:Boolean, param4:IVisualElement) : void
      {
         var _loc12_:Spacer = null;
         var _loc5_:TitleWindow = null;
         if(param4 is GWizPopUp && (param4 as GWizPopUp).resizable)
         {
            (_loc5_ = new ResizableTitleWindow()).setStyle("skinClass",ResizableTitleWindowSkin);
         }
         else
         {
            _loc5_ = new TitleWindow();
         }
         if(param4 is GWizPopUp)
         {
            GWizPopUp(param4).popupWindow = _loc5_;
         }
         var _loc6_:VerticalLayout = new VerticalLayout();
         _loc5_.percentHeight = 100;
         _loc5_.percentWidth = 100;
         _loc5_.layout = _loc6_;
         _loc5_.addElement(param4);
         var _loc7_:HGroup = null;
         var _loc8_:Button = null;
         var _loc9_:Button = null;
         var _loc10_:Button = null;
         var _loc11_:GWizPopUp = param4 as GWizPopUp;
         _loc5_.setStyle("backgroundColor",_loc11_.backgroundColor);
         (_loc7_ = new HGroup()).horizontalAlign = "center";
         _loc7_.percentWidth = 100;
         if(_loc11_.showHelp)
         {
            (_loc10_ = new Button()).label = "Help";
            _loc10_.addEventListener(MouseEvent.CLICK,_loc11_.onHelp);
         }
         if(_loc11_.okLabel != "")
         {
            _loc8_ = new Button();
            BindingUtils.bindProperty(_loc8_,"label",_loc11_,"okLabel");
            BindingUtils.bindProperty(_loc8_,"enabled",_loc11_,"okEnabled");
            _loc8_.addEventListener(MouseEvent.CLICK,_loc11_.onOk);
         }
         if(_loc11_.cancelLabel != "")
         {
            _loc9_ = new Button();
            BindingUtils.bindProperty(_loc9_,"label",_loc11_,"cancelLabel");
            _loc9_.addEventListener(MouseEvent.CLICK,_loc11_.onCancel);
         }
         _loc5_.title = _loc11_.title;
         _loc5_.addEventListener(CloseEvent.CLOSE,_loc11_.onCancel);
         if(_loc7_ != null && (_loc10_ || _loc8_ || _loc9_))
         {
            if(_loc10_)
            {
               _loc7_.addElement(_loc10_);
               (_loc12_ = new Spacer()).width = 50;
               _loc7_.addElement(_loc12_);
            }
            if(_loc8_)
            {
               _loc7_.addElement(_loc8_);
            }
            if(_loc9_)
            {
               _loc7_.addElement(_loc9_);
            }
            _loc5_.addElement(_loc7_);
            _loc6_.paddingBottom = 10;
         }
         PopUpManager.addPopUp(_loc5_,param1,param3);
         addOpenPopUp(param2);
         if(param4 is GWizPopUp && GWizPopUp(param4).fullScreen)
         {
            (param4 as GWizPopUp).resizeFullScreen();
         }
         PopUpManager.centerPopUp(_loc5_);
      }
      
      public static function centerPopUp(param1:DisplayObject) : void
      {
         var _loc2_:GWizPopUp = GWizPopUp(param1);
         if(_loc2_)
         {
            PopUpManager.centerPopUp(_loc2_.popupWindow);
         }
      }
      
      public static function removePopUp(param1:DisplayObject) : void
      {
         var _loc2_:TitleWindow = null;
         if(param1)
         {
            closeOpenPopUp(param1);
            while(!((param1 = param1.parent) is TitleWindow))
            {
            }
            _loc2_ = param1 as TitleWindow;
            PopUpManager.removePopUp(_loc2_);
         }
      }
      
      public static function popupShowing() : Boolean
      {
         return alertsShowing.length > 0 || openPopupList.length > 0;
      }
      
      public static function Show(param1:String = "", param2:String = "", param3:uint = 4, param4:Sprite = null, param5:Function = null, param6:Class = null, param7:uint = 4) : AlertPopup
      {
         var _loc8_:AlertPopup = null;
         var _loc9_:TitleWindow = null;
         var _loc10_:VerticalLayout = null;
         var _loc11_:Button = null;
         var _loc12_:Button = null;
         var _loc13_:Button = null;
         var _loc14_:Button = null;
         var _loc15_:HGroup = null;
         ZapHangOn();
         if(!alertIsShowing(param2))
         {
            if(!param4)
            {
               param4 = GWizSettings.docWindow;
            }
            _loc9_ = new TitleWindow();
            (_loc10_ = new VerticalLayout()).paddingBottom = 5;
            _loc10_.paddingLeft = 5;
            _loc10_.paddingRight = 5;
            _loc10_.paddingTop = 5;
            _loc10_.gap = 10;
            _loc10_.horizontalAlign = "center";
            _loc9_.height = 200;
            _loc9_.width = 300;
            _loc9_.layout = _loc10_;
            _loc9_.addElement(_loc8_ = new AlertPopup());
            _loc9_.title = param2;
            _loc8_.message = param1;
            _loc8_.closeHandler = alertCloser;
            _loc9_.setStyle("backgroundColor",!!(param3 & ERROR) ? ColorPalette.colorAsString(ColorPalette.secondaryb1) : (!!(param3 & WARN) ? ColorPalette.colorAsString(ColorPalette.complement1) : ColorPalette.colorAsString(ColorPalette.primary1)));
            _loc9_.setStyle("color","0x000000");
            (_loc15_ = new HGroup()).horizontalAlign = "center";
            if(param3 & YES)
            {
               (_loc13_ = new Button()).label = "Yes";
               _loc13_.name = "YES";
               _loc15_.addElement(_loc13_);
               _loc13_.addEventListener(MouseEvent.CLICK,_loc8_.onOk);
            }
            if(param3 & NO)
            {
               (_loc14_ = new Button()).label = "No";
               _loc14_.name = "NO";
               _loc15_.addElement(_loc14_);
               _loc14_.addEventListener(MouseEvent.CLICK,_loc8_.onOk);
            }
            if(param3 & OK)
            {
               (_loc11_ = new Button()).label = "OK";
               _loc11_.name = "OK";
               _loc15_.addElement(_loc11_);
               _loc11_.addEventListener(MouseEvent.CLICK,_loc8_.onOk);
            }
            if(param3 & CANCEL)
            {
               (_loc12_ = new Button()).label = "Cancel";
               _loc12_.name = "CANCEL";
               _loc15_.addElement(_loc12_);
               _loc12_.addEventListener(MouseEvent.CLICK,_loc8_.onOk);
            }
            _loc9_.addEventListener(CloseEvent.CLOSE,_loc8_.onOk);
            if(_loc15_.numElements == 0)
            {
               (_loc11_ = new Button()).label = "OK";
               _loc11_.name = "OK";
               _loc15_.addElement(_loc11_);
               _loc11_.addEventListener(MouseEvent.CLICK,_loc8_.onOk);
            }
            _loc9_.addElement(_loc15_);
            PopUpManager.addPopUp(_loc9_,param4,true);
            showAlert(param2,_loc9_,param5);
            PopUpManager.centerPopUp(_loc9_);
         }
         return _loc8_;
      }
      
      public static function HangOn(param1:String = "", param2:Sprite = null, param3:Function = null) : AlertPopup
      {
         var _loc4_:AlertPopup = null;
         if(!HangingOn())
         {
            hangOnCloser = param3;
            _loc4_ = Show(param1,HANG_ON_TITLE,4,param2,param3);
         }
         return _loc4_;
      }
      
      public static function HangingOn() : Boolean
      {
         return alertIsShowing(HANG_ON_TITLE);
      }
      
      public static function ZapHangOn() : void
      {
         var _loc1_:Object = null;
         if(alertIsShowing(HANG_ON_TITLE))
         {
            _loc1_ = alertsShowing.pop();
            PopUpManager.removePopUp(_loc1_.alert);
            if(hangOnCloser != null)
            {
               hangOnCloser();
               hangOnCloser = null;
            }
         }
      }
      
      public static function SendBob(param1:String) : void
      {
         var _loc2_:* = "Oh, oh: internal error = \'" + param1 + "\'\n";
         _loc2_ += "Please email your g-code to sales@cnccookbook.com so Bob can fix it!";
         Show(_loc2_,"Bob Needs Help!");
      }
      
      private static function alertIsShowing(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < alertsShowing.length)
         {
            if(alertsShowing[_loc3_].hasOwnProperty("title") && alertsShowing[_loc3_].title == param1)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private static function showAlert(param1:String, param2:TitleWindow, param3:Function) : void
      {
         var _loc4_:Object;
         (_loc4_ = new Object()).title = param1;
         _loc4_.alert = param2;
         _loc4_.closer = param3;
         alertsShowing.push(_loc4_);
      }
      
      private static function alertCloser(param1:Event) : void
      {
         var _loc6_:Object = null;
         var _loc7_:CloseEvent = null;
         var _loc2_:Array = [];
         var _loc3_:Object = param1.target;
         var _loc4_:uint = CANCEL;
         if(param1 is CloseEvent)
         {
            _loc4_ = (param1 as CloseEvent).detail;
         }
         else
         {
            switch(param1.target.name)
            {
               case "NO":
                  _loc4_ = NO;
                  break;
               case "YES":
                  _loc4_ = YES;
                  break;
               case "OK":
                  _loc4_ = OK;
            }
         }
         while(!(_loc3_ is TitleWindow))
         {
            _loc3_ = _loc3_.owner;
         }
         var _loc5_:int = 0;
         while(_loc5_ < alertsShowing.length)
         {
            if((_loc6_ = alertsShowing[_loc5_]).hasOwnProperty("alert") && _loc6_.alert != _loc3_)
            {
               _loc2_.push(_loc6_);
            }
            else if(_loc6_.hasOwnProperty("closer") && _loc6_.closer != null)
            {
               (_loc7_ = new CloseEvent(CloseEvent.CLOSE)).detail = _loc4_;
               _loc6_.closer(_loc7_);
            }
            _loc5_++;
         }
         alertsShowing = _loc2_;
         if(hangOnCloser != null)
         {
            hangOnCloser();
            hangOnCloser = null;
         }
      }
      
      private static function findOpen(param1:Class) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < openPopupList.length)
         {
            if(openPopupList[_loc2_] == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private static function addOpenPopUp(param1:Class) : void
      {
         if(findOpen(param1) == -1)
         {
            openPopupList.push(param1);
         }
      }
      
      private static function closeOpenPopUp(param1:DisplayObject) : void
      {
         var _loc2_:Array = [];
         var _loc3_:XML = describeType(param1);
         var _loc4_:* = _loc3_.@name.toString();
         _loc4_ = "[class " + _loc4_.substr(_loc4_.search("::") + 2,_loc4_.length) + "]";
         var _loc5_:int = 0;
         while(_loc5_ < openPopupList.length)
         {
            if(openPopupList[_loc5_].toString() != _loc4_)
            {
               _loc2_.push(openPopupList[_loc5_]);
            }
            _loc5_++;
         }
         openPopupList = _loc2_;
      }
   }
}
