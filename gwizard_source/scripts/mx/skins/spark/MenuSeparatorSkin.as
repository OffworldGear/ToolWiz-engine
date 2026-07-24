package mx.skins.spark
{
   import mx.core.IFlexModuleFactory;
   import mx.graphics.SolidColor;
   import spark.components.supportClasses.Skin;
   import spark.primitives.Rect;
   
   public class MenuSeparatorSkin extends Skin
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function MenuSeparatorSkin()
      {
         super();
         mx_internal::_document = this;
         this.mxmlContent = [this._MenuSeparatorSkin_Rect1_c()];
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
      
      private function _MenuSeparatorSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 1;
         _loc1_.height = 1;
         _loc1_.fill = this._MenuSeparatorSkin_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _MenuSeparatorSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 0;
         _loc1_.alpha = 0.55;
         return _loc1_;
      }
   }
}
