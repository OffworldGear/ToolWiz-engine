package cadcamwiz
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.events.PropertyChangeEvent;
   
   public class GWizCCWSettings implements IEventDispatcher
   {
      
      private static var _1753958196toolCribToolSelection:Boolean = true;
      
      public static var roughingInsType:int = 0;
      
      public static var roughingInsSize:int = 2;
      
      public static var finishingInsType:int = 0;
      
      public static var finishingInsSize:int = 2;
      
      public static var partingToolWidth:Number = 0.015;
      
      private static var _1528363413partingToolCarbide:Boolean = true;
      
      private static var _staticBindingEventDispatcher:EventDispatcher = new EventDispatcher();
       
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function GWizCCWSettings()
      {
         this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
         super();
      }
      
      [Bindable(event="propertyChange")]
      public static function get toolCribToolSelection() : Boolean
      {
         return GWizCCWSettings._1753958196toolCribToolSelection;
      }
      
      public static function set toolCribToolSelection(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWSettings._1753958196toolCribToolSelection;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWSettings,"toolCribToolSelection",_loc2_,param1));
               break;
            case _loc2_:
            case _loc3_:
         }
      }
      
      [Bindable(event="propertyChange")]
      public static function get partingToolCarbide() : Boolean
      {
         return GWizCCWSettings._1528363413partingToolCarbide;
      }
      
      public static function set partingToolCarbide(param1:Boolean) : void
      {
         var _loc3_:IEventDispatcher = null;
         var _loc2_:Object = GWizCCWSettings._1528363413partingToolCarbide;
         switch(param1)
         {
            default:
               _loc3_.dispatchEvent(PropertyChangeEvent.createUpdateEvent(GWizCCWSettings,"partingToolCarbide",_loc2_,param1));
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
