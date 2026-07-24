package skins
{
   import comps.GWizNumStep;
   import configinfo.GWizAbstractPrefs;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getQualifiedClassName;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GATracker;
   import utils.GWizUtils;
   
   public class GWizStylePalette implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizStylePalette");
      
      public static const ORIGINAL_FLAVA:String = "Original Flava";
      
      public static const DARK_MOOD:String = "Dark Mood";
      
      public static const LIGHTEN_UP:String = "Lighten Up";
      
      public static var currTheme:String = ORIGINAL_FLAVA;
      
      private static var _301302630BKGD_LVL_0:uint = 1382709;
      
      private static var _301302629BKGD_LVL_1:uint = 1844032;
      
      private static var _1758712788BKGD_SELECTED:uint = 3225697;
      
      public static const GARR_BLUE:uint = 5257;
      
      public static const BKGD_BLUE:uint = 1282038;
      
      public static var BkgdBlue:uint = !!GWizAbstractPrefs.isOEM ? uint(GARR_BLUE) : uint(BKGD_BLUE);
      
      public static const ORIGINAL_CHROME:uint = 13421772;
      
      public static const DK_TEXT:uint = 0;
      
      public static const LT_TEXT:uint = 16777215;
      
      private static var _1063571914textColor:uint = DK_TEXT;
      
      private static var _722830999borderColor:uint = 1282038;
      
      private static var _1356582991activeBorderColor:uint = 1282038;
      
      public static const cornerRadius:int = 5;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizStylePalette()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function onThemeChange() : void
      {
         GATracker.logPageView("Theme/" + currTheme,"Theme: " + currTheme);
         GWizStylePalette.borderColor = 0;
         if(GWizStylePalette.currTheme == GWizStylePalette.ORIGINAL_FLAVA)
         {
            GWizStylePalette.textColor = DK_TEXT;
            onThemeChangeAux();
            return;
         }
         if(GWizStylePalette.currTheme == GWizStylePalette.DARK_MOOD)
         {
            GWizStylePalette.BKGD_LVL_0 = 0;
            GWizStylePalette.BKGD_LVL_1 = 3816509;
            GWizStylePalette.BKGD_SELECTED = 4868940;
            GWizStylePalette.textColor = LT_TEXT;
         }
         else
         {
            GWizStylePalette.BKGD_LVL_0 = 14146011;
            GWizStylePalette.BKGD_LVL_1 = 15856630;
            GWizStylePalette.BKGD_SELECTED = 16777215;
            GWizStylePalette.textColor = DK_TEXT;
            GWizStylePalette.borderColor = BKGD_LVL_0;
         }
         GWizStylePalette.activeBorderColor = GWizStylePalette.BkgdBlue;
         onThemeChangeAux();
      }
      
      private static function onThemeChangeAux() : void
      {
         GWizNumStep.checkUnitsCC.callChain(null);
      }
      
      public static function refreshThemeProperties(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(!param1)
         {
            return;
         }
         try
         {
            if(param1.hasOwnProperty("ignoreForePanelThemes") && param1.ignoreForePanelThemes)
            {
               return;
            }
            _loc2_ = getQualifiedClassName(param1);
            switch(_loc2_)
            {
               case "spark.components::DropDownList":
                  param1.setStyle("borderVisible",true);
                  param1.setStyle("borderColor",GWizStylePalette.borderColor);
                  param1.setStyle("borderAlpha",1);
                  param1.setStyle("cornerRadius",3);
                  break;
               case "spark.components::CheckBox":
                  param1.setStyle("color",GWizStylePalette.textColor);
                  param1.setStyle("borderColor",GWizStylePalette.borderColor);
                  break;
               case "spark.components::RadioButton":
                  param1.setStyle("color",GWizStylePalette.textColor);
                  param1.setStyle("borderColor",GWizStylePalette.borderColor);
                  break;
               case "spark.components::Label":
                  param1.setStyle("color",GWizStylePalette.textColor);
                  break;
               case "spark.components::Button":
                  if(GWizStylePalette.currTheme != GWizStylePalette.ORIGINAL_FLAVA)
                  {
                     param1.setStyle("color",16777215);
                     if(!param1.enabled)
                     {
                        param1.setStyle("color",0);
                     }
                     param1.setStyle("chromeColor",GWizStylePalette.BkgdBlue);
                  }
                  else
                  {
                     param1.setStyle("color",0);
                     param1.setStyle("chromeColor",ORIGINAL_CHROME);
                  }
                  param1.setStyle("cornerRadius",GWizStylePalette.cornerRadius);
                  param1.setStyle("borderColor",GWizStylePalette.borderColor);
                  break;
               case "spark.components::TextInput":
               case "spark.components::TextArea":
                  param1.setStyle("cornerRadius",GWizStylePalette.cornerRadius);
                  param1.setStyle("borderColor",GWizStylePalette.borderColor);
                  break;
               default:
                  if(false && GWizUtils.debug)
                  {
                     log.debug("\'" + _loc2_ + "\'");
                  }
                  _loc3_ = 0;
                  while(_loc3_ < 1000)
                  {
                     _loc4_ = param1.getElementAt(_loc3_);
                     refreshThemeProperties(_loc4_);
                     _loc3_++;
                  }
            }
         }
         catch(e:Error)
         {
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get BKGD_LVL_0() : uint
      {
         return GWizStylePalette._301302630BKGD_LVL_0;
      }
      
      public static function set BKGD_LVL_0(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizStylePalette._301302630BKGD_LVL_0;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizStylePalette,"BKGD_LVL_0",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get BKGD_LVL_1() : uint
      {
         return GWizStylePalette._301302629BKGD_LVL_1;
      }
      
      public static function set BKGD_LVL_1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizStylePalette._301302629BKGD_LVL_1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizStylePalette,"BKGD_LVL_1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get BKGD_SELECTED() : uint
      {
         return GWizStylePalette._1758712788BKGD_SELECTED;
      }
      
      public static function set BKGD_SELECTED(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizStylePalette._1758712788BKGD_SELECTED;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizStylePalette,"BKGD_SELECTED",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get textColor() : uint
      {
         return GWizStylePalette._1063571914textColor;
      }
      
      public static function set textColor(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizStylePalette._1063571914textColor;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizStylePalette,"textColor",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get borderColor() : uint
      {
         return GWizStylePalette._722830999borderColor;
      }
      
      public static function set borderColor(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizStylePalette._722830999borderColor;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizStylePalette,"borderColor",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get activeBorderColor() : uint
      {
         return GWizStylePalette._1356582991activeBorderColor;
      }
      
      public static function set activeBorderColor(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizStylePalette._1356582991activeBorderColor;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizStylePalette,"activeBorderColor",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      public static function get staticEventDispatcher() : IEventDispatcher
      {
         return _staticBindingEventDispatcher;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
