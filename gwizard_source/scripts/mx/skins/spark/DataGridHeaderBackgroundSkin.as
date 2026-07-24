package mx.skins.spark
{
   import mx.core.IFlexModuleFactory;
   import mx.graphics.GradientEntry;
   import mx.graphics.LinearGradient;
   import mx.graphics.SolidColor;
   import spark.primitives.Rect;
   import spark.skins.SparkSkin;
   
   public class DataGridHeaderBackgroundSkin extends SparkSkin
   {
       
      
      private var __moduleFactoryInitialized:Boolean = false;
      
      public function DataGridHeaderBackgroundSkin()
      {
         super();
         mx_internal::_document = this;
         this.minWidth = 21;
         this.minHeight = 19;
         this.mxmlContent = [this._DataGridHeaderBackgroundSkin_Rect1_c(),this._DataGridHeaderBackgroundSkin_Rect2_c(),this._DataGridHeaderBackgroundSkin_Rect3_c(),this._DataGridHeaderBackgroundSkin_Rect4_c(),this._DataGridHeaderBackgroundSkin_Rect5_c()];
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
      
      private function _DataGridHeaderBackgroundSkin_Rect1_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._DataGridHeaderBackgroundSkin_SolidColor1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_SolidColor1_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_Rect2_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.bottom = 0;
         _loc1_.fill = this._DataGridHeaderBackgroundSkin_LinearGradient1_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_LinearGradient1_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._DataGridHeaderBackgroundSkin_GradientEntry1_c(),this._DataGridHeaderBackgroundSkin_GradientEntry2_c()];
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_GradientEntry1_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.85;
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_GradientEntry2_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 14211288;
         _loc1_.alpha = 0.85;
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_Rect3_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.height = 9;
         _loc1_.fill = this._DataGridHeaderBackgroundSkin_LinearGradient2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_LinearGradient2_c() : LinearGradient
      {
         var _loc1_:LinearGradient = new LinearGradient();
         _loc1_.rotation = 90;
         _loc1_.entries = [this._DataGridHeaderBackgroundSkin_GradientEntry3_c(),this._DataGridHeaderBackgroundSkin_GradientEntry4_c()];
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_GradientEntry3_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.0099;
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_GradientEntry4_c() : GradientEntry
      {
         var _loc1_:GradientEntry = new GradientEntry();
         _loc1_.color = 0;
         _loc1_.alpha = 0.0627;
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_Rect4_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.top = 0;
         _loc1_.height = 9;
         _loc1_.fill = this._DataGridHeaderBackgroundSkin_SolidColor2_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_SolidColor2_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 16777215;
         _loc1_.alpha = 0.33;
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_Rect5_c() : Rect
      {
         var _loc1_:Rect = new Rect();
         _loc1_.left = 0;
         _loc1_.right = 0;
         _loc1_.bottom = 0;
         _loc1_.height = 1;
         _loc1_.fill = this._DataGridHeaderBackgroundSkin_SolidColor3_c();
         _loc1_.initialized(this,null);
         return _loc1_;
      }
      
      private function _DataGridHeaderBackgroundSkin_SolidColor3_c() : SolidColor
      {
         var _loc1_:SolidColor = new SolidColor();
         _loc1_.color = 6908265;
         return _loc1_;
      }
   }
}
