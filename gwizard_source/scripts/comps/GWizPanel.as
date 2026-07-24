package comps
{
   import mx.events.PropertyChangeEvent;
   import spark.components.SkinnableContainer;
   
   public class GWizPanel extends SkinnableContainer
   {
       
      
      private var _110371416title:String = "";
      
      private var _1740488061darkBack:Boolean = true;
      
      private var _720898194borderAlpha:Number = 1.0;
      
      private var _1285191888backgroundAlpha:Number = 0.3;
      
      private var _1287124693backgroundColor:uint = 0;
      
      private var _722830999borderColor:uint = 0;
      
      public function GWizPanel()
      {
         super();
      }
      
      override protected function getCurrentSkinState() : String
      {
         return super.getCurrentSkinState();
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         super.partAdded(param1,param2);
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         super.partRemoved(param1,param2);
      }
      
      [Bindable(event="propertyChange")]
      public function get title() : String
      {
         return this._110371416title;
      }
      
      public function set title(param1:String) : void
      {
         var _loc2_:Object = this._110371416title;
         if(_loc2_ !== param1)
         {
            this._110371416title = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"title",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get darkBack() : Boolean
      {
         return this._1740488061darkBack;
      }
      
      public function set darkBack(param1:Boolean) : void
      {
         var _loc2_:Object = this._1740488061darkBack;
         if(_loc2_ !== param1)
         {
            this._1740488061darkBack = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"darkBack",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderAlpha() : Number
      {
         return this._720898194borderAlpha;
      }
      
      public function set borderAlpha(param1:Number) : void
      {
         var _loc2_:Object = this._720898194borderAlpha;
         if(_loc2_ !== param1)
         {
            this._720898194borderAlpha = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderAlpha",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundAlpha() : Number
      {
         return this._1285191888backgroundAlpha;
      }
      
      public function set backgroundAlpha(param1:Number) : void
      {
         var _loc2_:Object = this._1285191888backgroundAlpha;
         if(_loc2_ !== param1)
         {
            this._1285191888backgroundAlpha = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundAlpha",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get backgroundColor() : uint
      {
         return this._1287124693backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         var _loc2_:Object = this._1287124693backgroundColor;
         if(_loc2_ !== param1)
         {
            this._1287124693backgroundColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"backgroundColor",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get borderColor() : uint
      {
         return this._722830999borderColor;
      }
      
      public function set borderColor(param1:uint) : void
      {
         var _loc2_:Object = this._722830999borderColor;
         if(_loc2_ !== param1)
         {
            this._722830999borderColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"borderColor",_loc2_,param1));
            }
         }
      }
   }
}
