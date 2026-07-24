package utils
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.events.PropertyChangeEvent;
   
   public class ColorPalette implements IEventDispatcher
   {
      
      private static var _1167805841primary1:uint = 1406903;
      
      private static var _1167805840primary2:uint = 2570822;
      
      private static var _1167805839primary3:uint = 6442;
      
      private static var _1167805838primary4:uint = 5481172;
      
      private static var _1167805837primary5:uint = 8631508;
      
      private static var _267251812secondarya1:uint = 1292627;
      
      private static var _267251813secondarya2:uint = 2904884;
      
      private static var _267251814secondarya3:uint = 12811;
      
      private static var _267251815secondarya4:uint = 5234286;
      
      private static var _267251816secondarya5:uint = 8642199;
      
      private static var _267251843secondaryb1:uint = 12590092;
      
      private static var _267251844secondaryb2:uint = 7159610;
      
      private static var _267251845secondaryb3:uint = 4326912;
      
      private static var _267251846secondaryb4:uint = 15885398;
      
      private static var _267251847secondaryb5:uint = 15898767;
      
      private static var _395976395complement1:uint = 14385165;
      
      private static var _395976396complement2:uint = 7165754;
      
      private static var _395976397complement3:uint = 4334848;
      
      private static var _395976398complement4:uint = 15904086;
      
      private static var _395976399complement5:uint = 15910543;
      
      private static var _98615854gray1:uint = 6710886;
      
      private static var _98615855gray2:uint = 3355443;
      
      private static var _98615856gray3:uint = 1118481;
      
      private static var _98615857gray4:uint = 13421772;
      
      private static var _98615858gray5:uint = 15658734;
      
      private static var _196798998alternatea1:uint = 6755585;
      
      private static var _196798997alternatea2:uint = 4464664;
      
      private static var _196798996alternatea3:uint = 3541504;
      
      private static var _196798995alternatea4:uint = 16290168;
      
      private static var _196798994alternatea5:uint = 16309718;
      
      private static var _196798967alternateb1:uint = 3934043;
      
      private static var _196798966alternateb2:uint = 2955322;
      
      private static var _196798965alternateb3:uint = 1900845;
      
      private static var _196798964alternateb4:uint = 13402616;
      
      private static var _196798963alternateb5:uint = 15522040;
      
      private static var _1450098962greenLightOn:uint = 1048335;
      
      private static var _2003394716greenLightOff:uint = 12811;
      
      private static var _1225563076redLightOn:uint = 16711680;
      
      private static var _662250454redLightOff:uint = 7342602;
      
      private static var _1295234430lightBulbOn:uint = 16433152;
      
      private static var _1497561520lightBulbOff:uint = 3352320;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function ColorPalette()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function colorAsString(param1:uint) : String
      {
         var _loc2_:String = "";
         var _loc3_:String = "FEDCBA";
         var _loc4_:uint;
         if((_loc4_ = decBinLen(param1)) % 4 > 0)
         {
            while(_loc4_ % 4 > 0)
            {
               _loc4_++;
            }
         }
         if((_loc4_ /= 4) % 4 > 0)
         {
            while(_loc4_ % 4 > 0)
            {
               _loc4_++;
            }
         }
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            if((param1 & 15 << _loc5_ * 4) >> _loc5_ * 4 > 9)
            {
               _loc2_ = _loc3_.charAt(15 - ((param1 & 15 << _loc5_ * 4) >> _loc5_ * 4)) + _loc2_;
            }
            else
            {
               _loc2_ = String((param1 & 15 << _loc5_ * 4) >> _loc5_ * 4) + _loc2_;
            }
            _loc5_++;
         }
         if(_loc2_ == "")
         {
            _loc2_ = "0000";
         }
         return "0x" + _loc2_;
      }
      
      private static function decBinLen(param1:uint) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:Boolean = true;
         if(param1 != 0)
         {
            _loc2_ = 1;
            while(_loc3_)
            {
               if(param1 >> _loc2_ == 0)
               {
                  _loc3_ = false;
               }
               else
               {
                  _loc2_++;
               }
            }
         }
         return _loc2_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get primary1() : uint
      {
         return ColorPalette._1167805841primary1;
      }
      
      public static function set primary1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1167805841primary1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"primary1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get primary2() : uint
      {
         return ColorPalette._1167805840primary2;
      }
      
      public static function set primary2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1167805840primary2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"primary2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get primary3() : uint
      {
         return ColorPalette._1167805839primary3;
      }
      
      public static function set primary3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1167805839primary3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"primary3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get primary4() : uint
      {
         return ColorPalette._1167805838primary4;
      }
      
      public static function set primary4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1167805838primary4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"primary4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get primary5() : uint
      {
         return ColorPalette._1167805837primary5;
      }
      
      public static function set primary5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1167805837primary5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"primary5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondarya1() : uint
      {
         return ColorPalette._267251812secondarya1;
      }
      
      public static function set secondarya1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251812secondarya1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondarya1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondarya2() : uint
      {
         return ColorPalette._267251813secondarya2;
      }
      
      public static function set secondarya2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251813secondarya2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondarya2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondarya3() : uint
      {
         return ColorPalette._267251814secondarya3;
      }
      
      public static function set secondarya3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251814secondarya3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondarya3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondarya4() : uint
      {
         return ColorPalette._267251815secondarya4;
      }
      
      public static function set secondarya4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251815secondarya4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondarya4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondarya5() : uint
      {
         return ColorPalette._267251816secondarya5;
      }
      
      public static function set secondarya5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251816secondarya5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondarya5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondaryb1() : uint
      {
         return ColorPalette._267251843secondaryb1;
      }
      
      public static function set secondaryb1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251843secondaryb1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondaryb1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondaryb2() : uint
      {
         return ColorPalette._267251844secondaryb2;
      }
      
      public static function set secondaryb2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251844secondaryb2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondaryb2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondaryb3() : uint
      {
         return ColorPalette._267251845secondaryb3;
      }
      
      public static function set secondaryb3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251845secondaryb3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondaryb3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondaryb4() : uint
      {
         return ColorPalette._267251846secondaryb4;
      }
      
      public static function set secondaryb4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251846secondaryb4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondaryb4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get secondaryb5() : uint
      {
         return ColorPalette._267251847secondaryb5;
      }
      
      public static function set secondaryb5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._267251847secondaryb5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"secondaryb5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get complement1() : uint
      {
         return ColorPalette._395976395complement1;
      }
      
      public static function set complement1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._395976395complement1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"complement1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get complement2() : uint
      {
         return ColorPalette._395976396complement2;
      }
      
      public static function set complement2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._395976396complement2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"complement2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get complement3() : uint
      {
         return ColorPalette._395976397complement3;
      }
      
      public static function set complement3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._395976397complement3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"complement3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get complement4() : uint
      {
         return ColorPalette._395976398complement4;
      }
      
      public static function set complement4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._395976398complement4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"complement4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get complement5() : uint
      {
         return ColorPalette._395976399complement5;
      }
      
      public static function set complement5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._395976399complement5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"complement5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get gray1() : uint
      {
         return ColorPalette._98615854gray1;
      }
      
      public static function set gray1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._98615854gray1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"gray1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get gray2() : uint
      {
         return ColorPalette._98615855gray2;
      }
      
      public static function set gray2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._98615855gray2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"gray2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get gray3() : uint
      {
         return ColorPalette._98615856gray3;
      }
      
      public static function set gray3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._98615856gray3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"gray3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get gray4() : uint
      {
         return ColorPalette._98615857gray4;
      }
      
      public static function set gray4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._98615857gray4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"gray4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get gray5() : uint
      {
         return ColorPalette._98615858gray5;
      }
      
      public static function set gray5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._98615858gray5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"gray5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternatea1() : uint
      {
         return ColorPalette._196798998alternatea1;
      }
      
      public static function set alternatea1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798998alternatea1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternatea1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternatea2() : uint
      {
         return ColorPalette._196798997alternatea2;
      }
      
      public static function set alternatea2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798997alternatea2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternatea2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternatea3() : uint
      {
         return ColorPalette._196798996alternatea3;
      }
      
      public static function set alternatea3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798996alternatea3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternatea3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternatea4() : uint
      {
         return ColorPalette._196798995alternatea4;
      }
      
      public static function set alternatea4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798995alternatea4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternatea4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternatea5() : uint
      {
         return ColorPalette._196798994alternatea5;
      }
      
      public static function set alternatea5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798994alternatea5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternatea5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternateb1() : uint
      {
         return ColorPalette._196798967alternateb1;
      }
      
      public static function set alternateb1(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798967alternateb1;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternateb1",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternateb2() : uint
      {
         return ColorPalette._196798966alternateb2;
      }
      
      public static function set alternateb2(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798966alternateb2;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternateb2",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternateb3() : uint
      {
         return ColorPalette._196798965alternateb3;
      }
      
      public static function set alternateb3(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798965alternateb3;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternateb3",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternateb4() : uint
      {
         return ColorPalette._196798964alternateb4;
      }
      
      public static function set alternateb4(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798964alternateb4;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternateb4",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get alternateb5() : uint
      {
         return ColorPalette._196798963alternateb5;
      }
      
      public static function set alternateb5(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._196798963alternateb5;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"alternateb5",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get greenLightOn() : uint
      {
         return ColorPalette._1450098962greenLightOn;
      }
      
      public static function set greenLightOn(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1450098962greenLightOn;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"greenLightOn",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get greenLightOff() : uint
      {
         return ColorPalette._2003394716greenLightOff;
      }
      
      public static function set greenLightOff(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._2003394716greenLightOff;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"greenLightOff",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get redLightOn() : uint
      {
         return ColorPalette._1225563076redLightOn;
      }
      
      public static function set redLightOn(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1225563076redLightOn;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"redLightOn",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get redLightOff() : uint
      {
         return ColorPalette._662250454redLightOff;
      }
      
      public static function set redLightOff(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._662250454redLightOff;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"redLightOff",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get lightBulbOn() : uint
      {
         return ColorPalette._1295234430lightBulbOn;
      }
      
      public static function set lightBulbOn(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1295234430lightBulbOn;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"lightBulbOn",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get lightBulbOff() : uint
      {
         return ColorPalette._1497561520lightBulbOff;
      }
      
      public static function set lightBulbOff(param1:uint) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = ColorPalette._1497561520lightBulbOff;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(ColorPalette,"lightBulbOff",_loc2_,param1));
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
