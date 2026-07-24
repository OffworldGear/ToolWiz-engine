package mx.skins.spark
{
   import mx.binding.BindingManager;
   import mx.core.IFlexModuleFactory;
   import mx.events.PropertyChangeEvent;
   import mx.graphics.SolidColor;
   import spark.primitives.Path;
   import spark.skins.SparkSkin;
   
   public class MenuCheck extends SparkSkin
   {
      
      private static const symbols:Array = ["checkFill"];
       
      
      private var _94627080check:Path;
      
      private var _398166699checkFill:SolidColor;
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function MenuCheck()
      {
         super();
         mx_internal::_document = this;
         this.layoutDirection = "ltr";
         this.mxmlContent = [this._MenuCheck_Path1_i()];
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
      
      private function _MenuCheck_Path1_i() : Path
      {
         var _loc1_:Path = new Path();
         _loc1_.data = "M 0 2 L 3 4.4 L 7 0 L 7 3 L 3 7 L 0 4.6 L 0 2 Z";
         _loc1_.fill = this._MenuCheck_SolidColor1_i();
         _loc1_.initialized(this,"check");
         this.check = _loc1_;
         BindingManager.executeBindings(this,"check",this.check);
         return _loc1_;
      }
      
      private function _MenuCheck_SolidColor1_i() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         this.checkFill = _loc1_;
         BindingManager.executeBindings(this,"checkFill",this.checkFill);
         return _loc1_;
      }
      
      [Bindable(event="propertyChange")]
      public function get check() : Path
      {
         return this._94627080check;
      }
      
      public function set check(param1:Path) : void
      {
         var _loc2_:Object = this._94627080check;
         if(_loc2_ !== param1)
         {
            this._94627080check = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"check",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get checkFill() : SolidColor
      {
         return this._398166699checkFill;
      }
      
      public function set checkFill(param1:SolidColor) : void
      {
         var _loc2_:Object = this._398166699checkFill;
         if(_loc2_ !== param1)
         {
            this._398166699checkFill = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"checkFill",_loc2_,param1));
            }
         }
      }
   }
}
