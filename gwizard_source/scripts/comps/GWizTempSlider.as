package comps
{
   import com.TrackHighlightSlider.HSlider;
   import flash.events.MouseEvent;
   import mx.core.IFlexModuleFactory;
   import mx.events.FlexEvent;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   
   public class GWizTempSlider extends HSlider
   {
      
      private static const log:ILogger = Log.getLogger("GWizTempSlider");
      
      private static const GREEN_COLOR:uint = 65346;
      
      private static const YELLOW_COLOR:uint = 16774656;
      
      private static const ORANGE_COLOR:uint = 16743936;
      
      private static const RED_COLOR:uint = 16716288;
      
      public static const GREEN_PCT:Number = 0.85;
      
      public static const YELLOW_PCT:Number = 0.9;
      
      public static const ORANGE_PCT:Number = 0.95;
      
      public static const RED_PCT:Number = 1;
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      private var _678927291percent:Number = 0;
      
      public function GWizTempSlider()
      {
         super();
         this.minimum = 0;
         this.maximum = 100;
         this.snapInterval = 0.0001;
         this.stepSize = 0.0001;
         this.addEventListener("valueCommit",this.___GWizTempSlider_HSlider1_valueCommit);
         this.addEventListener("creationComplete",this.___GWizTempSlider_HSlider1_creationComplete);
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         var factory:IFlexModuleFactory = param1;
         super.moduleFactory = factory;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
         if(!this.styleDeclaration)
         {
            this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
         }
         this.styleDeclaration.defaultFactory = function():void
         {
            this.liveDragging = true;
         };
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      private function onCC() : void
      {
      }
      
      private function recalc() : void
      {
         var _loc1_:uint = GREEN_COLOR;
         this.percent = (value - minimum) / (maximum - minimum);
         this.percent = Math.max(0,this.percent);
         if(this.percent <= GREEN_PCT)
         {
            _loc1_ = GREEN_COLOR;
         }
         else if(this.percent <= YELLOW_PCT)
         {
            _loc1_ = YELLOW_COLOR;
         }
         else if(this.percent <= ORANGE_PCT)
         {
            _loc1_ = ORANGE_COLOR;
         }
         else
         {
            _loc1_ = RED_COLOR;
         }
         this.accentColor = _loc1_;
         invalidateDisplayList();
      }
      
      protected function deadMouse(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
      }
      
      public function ___GWizTempSlider_HSlider1_valueCommit(param1:FlexEvent) : void
      {
         this.recalc();
      }
      
      public function ___GWizTempSlider_HSlider1_creationComplete(param1:FlexEvent) : void
      {
         this.onCC();
      }
      
      [Bindable(event="propertyChange")]
      public function get percent() : Number
      {
         return this._678927291percent;
      }
      
      public function set percent(param1:Number) : void
      {
         var _loc2_:Object = this._678927291percent;
         if(_loc2_ !== param1)
         {
            this._678927291percent = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"percent",_loc2_,param1));
            }
         }
      }
   }
}
