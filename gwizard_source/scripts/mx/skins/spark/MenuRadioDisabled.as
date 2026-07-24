package mx.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import spark.primitives.Ellipse;
   import spark.skins.SparkSkin;
   
   public class MenuRadioDisabled extends SparkSkin
   {
      
      private static const symbols:Array = ["radioFill"];
       
      
      private var _108270587radio:Ellipse;
      
      private var _970651618radioFill:SolidColor;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function MenuRadioDisabled()
      {
         super();
         mx_internal::_document = this;
         this.alpha = 0.5;
         this.mxmlContent = [this._MenuRadioDisabled_Ellipse1_i()];
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this.__moduleFactoryInitialized)
         {
            return;
         }
         this.__moduleFactoryInitialized = true;
      }
      
      override public function initialize() : void
      {
         super.initialize();
      }
      
      override public function get symbolItems() : Array
      {
         return symbols;
      }
      
      private function _MenuRadioDisabled_Ellipse1_i() : Ellipse
      {
         var _loc1_:Ellipse = new Ellipse();
         _loc1_.width = 5;
         _loc1_.height = 5;
         _loc1_.fill = this._MenuRadioDisabled_SolidColor1_i();
         _loc1_.initialized(this,"radio");
         this.radio = _loc1_;
         BindingManager.executeBindings(this,"radio",this.radio);
         return _loc1_;
      }
      
      private function _MenuRadioDisabled_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         this.radioFill = _loc1_;
         BindingManager.executeBindings(this,"radioFill",this.radioFill);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get radio() : Ellipse
      {
         return this._108270587radio;
      }
      
      public function set radio(param1:Ellipse) : void
      {
         var _loc2_:Object = this._108270587radio;
         if(_loc2_ !== param1)
         {
            this._108270587radio = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radio",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get radioFill() : SolidColor
      {
         return this._970651618radioFill;
      }
      
      public function set radioFill(param1:SolidColor) : void
      {
         var _loc2_:Object = this._970651618radioFill;
         if(_loc2_ !== param1)
         {
            this._970651618radioFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"radioFill",_loc2_,param1));
            }
         }
      }
   }
}
