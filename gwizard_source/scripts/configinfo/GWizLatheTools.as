package configinfo
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.collections.ArrayCollection;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import utils.GWizUtils;
   
   public class GWizLatheTools implements IEventDispatcher
   {
      
      private static const log:ILogger = Log.getLogger("GWizLatheTools");
      
      private static var _526292267insTypes:ArrayCollection = new ArrayCollection([{
         "label":"C - 80 degree diamond",
         "dim":"Side length",
         "maxMult":0.67,
         "finish":0.15,
         "medium":0.41,
         "rough":1
      },{
         "label":"D - 55 degree diamond",
         "dim":"Side length",
         "maxMult":0.5,
         "finish":0.3,
         "medium":0.7,
         "rough":1
      },{
         "label":"K - 55 degree parallelogram",
         "dim":"Side length",
         "maxMult":0.5,
         "finish":0.3,
         "medium":0.7,
         "rough":1
      },{
         "label":"R - round",
         "dim":"Diameter",
         "maxMult":0.4,
         "finish":0.12,
         "medium":0.28,
         "rough":1
      },{
         "label":"T - triangle",
         "dim":"Side length",
         "maxMult":0.5,
         "finish":0.15,
         "medium":0.38,
         "rough":1
      },{
         "label":"V - 35 degree diamond",
         "dim":"Side length",
         "maxMult":0.25,
         "finish":0.3,
         "medium":0.7,
         "rough":1
      },{
         "label":"W - trigon",
         "dim":"Side length (of 6 sides)",
         "maxMult":0.25,
         "finish":0.38,
         "medium":0.63,
         "rough":1
      }]);
      
      private static var _524901700insSizes:ArrayCollection = new ArrayCollection([{
         "label":"ANSI 2 - 1/4 IC",
         "C":6,
         "D":7,
         "K":7,
         "R":6,
         "T":11,
         "V":11,
         "W":4
      },{
         "label":"ANSI 2.5 - 5/16 IC",
         "C":8,
         "D":9,
         "K":9,
         "R":7,
         "T":13,
         "V":13,
         "W":5
      },{
         "label":"ANSI 3 - 3/8 IC",
         "C":9,
         "D":11,
         "K":11,
         "R":9,
         "T":16,
         "V":16,
         "W":6
      },{
         "label":"ANSI 3.5 - 7/16 IC",
         "C":11,
         "D":13,
         "K":13,
         "R":11,
         "T":19,
         "V":19,
         "W":7
      },{
         "label":"ANSI 4 - 1/2 IC",
         "C":12,
         "D":15,
         "K":15,
         "R":12,
         "T":22,
         "V":22,
         "W":8
      },{
         "label":"ANSI 4.5 - 9/16 IC",
         "C":14,
         "D":17,
         "K":17,
         "R":14,
         "T":24,
         "V":24,
         "W":9
      },{
         "label":"ANSI 5 - 5/8 IC",
         "C":16,
         "D":19,
         "K":19,
         "R":15,
         "T":27,
         "V":27,
         "W":10
      },{
         "label":"ANSI 5.5 - 11/16 IC",
         "C":17,
         "D":21,
         "K":21,
         "R":17,
         "T":30,
         "V":30,
         "W":11
      },{
         "label":"ANSI 6 - 3/4 IC",
         "C":19,
         "D":23,
         "K":23,
         "R":19,
         "T":33,
         "V":33,
         "W":13
      },{
         "label":"ANSI 7 - 7/8 IC",
         "C":22,
         "D":27,
         "K":27,
         "R":22,
         "T":38,
         "V":38,
         "W":15
      },{
         "label":"ANSI 8 - 1 IC",
         "C":25,
         "D":31,
         "K":31,
         "R":25,
         "T":44,
         "V":44,
         "W":17
      },{
         "label":"ANSI 10 - 1-1/4 IC",
         "C":32,
         "D":28,
         "K":28,
         "R":31,
         "T":54,
         "V":54,
         "W":21
      }]);
      
      public static const CUT_TYPE_ROUGH:int = 0;
      
      public static const CUT_TYPE_MEDIUM:int = 0;
      
      public static const CUT_TYPE_FINISH:int = 0;
      
      private static var _605552471cutTypes:ArrayCollection = new ArrayCollection([{"label":"Rough"},{"label":"Medium"},{"label":"Finish"}]);
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizLatheTools()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      public static function getInsertDesc(param1:Object, param2:int, param3:Number) : String
      {
         return "Insert: " + param1.label + "; " + GWizLatheTools.insSizes.getItemAt(param2).label + "; " + param3 + " deg. lead angle";
      }
      
      public static function turningCutDepth(param1:Object, param2:int, param3:int, param4:Number) : Object
      {
         var _loc8_:String = null;
         var _loc9_:Number = NaN;
         var _loc5_:Object = new Object();
         if(param1 && param1.hasOwnProperty("dim") && param2 >= 0)
         {
            _loc5_.dimName = param1.dim;
            _loc8_ = (_loc8_ = param1.label).charAt(0);
            _loc9_ = GWizLatheTools.insSizes.getItemAt(param2)[_loc8_];
            _loc5_.dim = _loc9_ / 25.4;
         }
         else
         {
            _loc5_.dimName = "Size";
            _loc5_.dim = 0.125;
         }
         var _loc6_:Number = !!param1 ? Number(param1.maxMult) : Number(0);
         _loc5_.doc = _loc5_.dim * _loc6_;
         var _loc7_:String = cutTypes.getItemAt(param3).label;
         switch(_loc7_)
         {
            case "Rough":
               break;
            case "Medium":
               _loc5_.doc *= param1.medium;
               break;
            case "Finish":
               _loc5_.doc *= param1.finish;
         }
         _loc5_.doc = int(_loc5_.doc * 1000) / 1000;
         _loc5_.infeed = _loc5_.doc * Math.cos(GWizUtils.radians(param4));
         _loc5_.infeed = int(_loc5_.infeed * 10000) / 10000;
         return _loc5_;
      }
      
      [Bindable(event="propertyChange")]
      public static function get insTypes() : ArrayCollection
      {
         return GWizLatheTools._526292267insTypes;
      }
      
      public static function set insTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizLatheTools._526292267insTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizLatheTools,"insTypes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get insSizes() : ArrayCollection
      {
         return GWizLatheTools._524901700insSizes;
      }
      
      public static function set insSizes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizLatheTools._524901700insSizes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizLatheTools,"insSizes",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get cutTypes() : ArrayCollection
      {
         return GWizLatheTools._605552471cutTypes;
      }
      
      public static function set cutTypes(param1:ArrayCollection) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizLatheTools._605552471cutTypes;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizLatheTools,"cutTypes",_loc2_,param1));
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
