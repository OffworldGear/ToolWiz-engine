package bubbletip
{
   import mx.binding.BindingManager;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import spark.primitives.Ellipse;
   
   public class controlOverlay extends Ellipse
   {
       
      
      private var _88844982outerDocument:GWizBubbleTip;
      
      private var _983567224solidColor:SolidColor;
      
      public function controlOverlay()
      {
         super();
         this.depth = 10000;
         this.fill = this._controlOverlay_SolidColor1_i();
      }
      
      private function _controlOverlay_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         this.solidColor = _loc1_;
         BindingManager.executeBindings(this,"solidColor",this.solidColor);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get outerDocument() : GWizBubbleTip
      {
         return this._88844982outerDocument;
      }
      
      public function set outerDocument(param1:GWizBubbleTip) : void
      {
         var _loc2_:Object = this._88844982outerDocument;
         if(_loc2_ !== param1)
         {
            this._88844982outerDocument = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get solidColor() : SolidColor
      {
         return this._983567224solidColor;
      }
      
      public function set solidColor(param1:SolidColor) : void
      {
         var _loc2_:Object = this._983567224solidColor;
         if(_loc2_ !== param1)
         {
            this._983567224solidColor = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"solidColor",_loc2_,param1));
            }
         }
      }
   }
}
