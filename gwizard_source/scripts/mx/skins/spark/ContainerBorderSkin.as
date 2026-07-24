package mx.skins.spark
{
   public class ContainerBorderSkin extends BorderSkin
   {
       
      
      public function ContainerBorderSkin()
      {
         super();
      }
      
      override public function get contentItems() : Array
      {
         return null;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = getStyle("cornerRadius");
         if(cornerRadius != _loc3_)
         {
            cornerRadius = _loc3_;
         }
         if(isNaN(getStyle("backgroundColor")))
         {
            background.visible = false;
         }
         else
         {
            background.visible = true;
            bgFill.color = getStyle("backgroundColor");
            bgFill.alpha = getStyle("backgroundAlpha");
         }
         super.updateDisplayList(param1,param2);
      }
   }
}
