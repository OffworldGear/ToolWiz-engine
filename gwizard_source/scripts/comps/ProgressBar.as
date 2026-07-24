package comps
{
   import comps.skins.ProgressBarSkin;
   import flash.events.IEventDispatcher;
   import flash.events.ProgressEvent;
   import mx.events.PropertyChangeEvent;
   import spark.components.supportClasses.SkinnableComponent;
   import utils.ColorPalette;
   
   public class ProgressBar extends SkinnableComponent
   {
       
      
      private var _755159350progressColor:uint;
      
      private var _437240161progressColorHilight:uint;
      
      private var _1064538126minimum:Number = 0;
      
      private var _maximum:Number = 1;
      
      private var _value:Number = 0;
      
      private var _label:String;
      
      private var labelPrefix:String = "";
      
      private var _eventSource:IEventDispatcher;
      
      public function ProgressBar()
      {
         this._755159350progressColor = ColorPalette.secondarya2;
         this._437240161progressColorHilight = ColorPalette.secondarya4;
         super();
         this.labelPrefix = this.label;
         setStyle("skinClass",ProgressBarSkin);
      }
      
      public function get eventSource() : IEventDispatcher
      {
         return this._eventSource;
      }
      
      public function set eventSource(param1:IEventDispatcher) : void
      {
         if(this._eventSource != param1)
         {
            this.removeEventSourceListeners();
            this._eventSource = param1;
            this.addEventSourceListeners();
         }
      }
      
      protected function removeEventSourceListeners() : void
      {
         if(this.eventSource)
         {
            this.eventSource.removeEventListener(ProgressEvent.PROGRESS,this.eventSource_progressHandler);
         }
      }
      
      protected function addEventSourceListeners() : void
      {
         if(this.eventSource)
         {
            this.eventSource.addEventListener(ProgressEvent.PROGRESS,this.eventSource_progressHandler,false,0,true);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get label() : String
      {
         return this._label;
      }
      
      private function set _102727412label(param1:String) : void
      {
         this.labelPrefix = param1;
         this.updateLabel();
      }
      
      [Bindable(event="propertyChange")]
      public function get value() : Number
      {
         return this._value;
      }
      
      private function set _111972721value(param1:Number) : void
      {
         this._value = param1;
         this.updateLabel();
      }
      
      [Bindable(event="propertyChange")]
      public function get maximum() : Number
      {
         return this._maximum;
      }
      
      private function set _844740128maximum(param1:Number) : void
      {
         this._maximum = param1;
         this.updateLabel();
      }
      
      private function updateLabel() : void
      {
         var _loc1_:String = this._label;
         this._label = (this.labelPrefix == "" ? "" : this.labelPrefix + " : ") + String(Math.floor(this.value / this.maximum * 100)) + "%";
         dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"label",_loc1_,this._label));
      }
      
      protected function eventSource_progressHandler(param1:ProgressEvent) : void
      {
         this.value = param1.bytesLoaded;
         this.maximum = param1.bytesTotal;
         this.updateLabel();
      }
      
      [Bindable(event="propertyChange")]
      public function get progressColor() : uint
      {
         return this._755159350progressColor;
      }
      
      public function set progressColor(param1:uint) : void
      {
         var _loc2_:Object = this._755159350progressColor;
         if(_loc2_ !== param1)
         {
            this._755159350progressColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"progressColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get progressColorHilight() : uint
      {
         return this._437240161progressColorHilight;
      }
      
      public function set progressColorHilight(param1:uint) : void
      {
         var _loc2_:Object = this._437240161progressColorHilight;
         if(_loc2_ !== param1)
         {
            this._437240161progressColorHilight = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"progressColorHilight",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get minimum() : Number
      {
         return this._1064538126minimum;
      }
      
      public function set minimum(param1:Number) : void
      {
         var _loc2_:Object = this._1064538126minimum;
         if(_loc2_ !== param1)
         {
            this._1064538126minimum = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"minimum",_loc2_,param1));
            }
         }
      }
      
      public function set label(param1:String) : void
      {
         var _loc2_:Object = this.label;
         if(_loc2_ !== param1)
         {
            this._102727412label = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"label",_loc2_,param1));
            }
         }
      }
      
      public function set value(param1:Number) : void
      {
         var _loc2_:Object = this.value;
         if(_loc2_ !== param1)
         {
            this._111972721value = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"value",_loc2_,param1));
            }
         }
      }
      
      public function set maximum(param1:Number) : void
      {
         var _loc2_:Object = this.maximum;
         if(_loc2_ !== param1)
         {
            this._844740128maximum = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"maximum",_loc2_,param1));
            }
         }
      }
   }
}
