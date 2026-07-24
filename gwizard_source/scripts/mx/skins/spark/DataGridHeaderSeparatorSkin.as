package mx.skins.spark
{
   import mx.core.IFlexModuleFactory;
   import mx.graphics.SolidColor;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class DataGridHeaderSeparatorSkin extends SparkSkin
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function DataGridHeaderSeparatorSkin()
      {
         super();
         mx_internal::_document = this;
         this.width = 2;
         this.height = 10;
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.mxmlContent = [this._DataGridHeaderSeparatorSkin_Rect1_c(),this._DataGridHeaderSeparatorSkin_Rect2_c()];
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
      
      override protected function initializationComplete() : void
      {
         useChromeColor = true;
         super.initializationComplete();
      }
      
      private function _DataGridHeaderSeparatorSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 0;
         _loc1_.bottom = 1;
         _loc1_.left = 0;
         _loc1_.width = 1;
         _loc1_.fill = this._DataGridHeaderSeparatorSkin_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderSeparatorSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.35;
         return _loc1_;
      }
      
      private function _DataGridHeaderSeparatorSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.top = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.width = 1;
         _loc1_.fill = this._DataGridHeaderSeparatorSkin_SolidColor2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderSeparatorSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 6908265;
         return _loc1_;
      }
   }
}
