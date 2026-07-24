package mx.skins.spark
{
   import flash.display.Graphics;
   import mx.skins.ProgrammaticSkin;
   
   public class DataGridSortArrow extends ProgrammaticSkin
   {
       
      
      public function DataGridSortArrow()
      {
         super();
      }
      
      override public function get measuredWidth() : Number
      {
         return 6;
      }
      
      override public function get measuredHeight() : Number
      {
         return 6;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         var _loc3_:Graphics = graphics;
         var _loc4_:Number = name == "sortArrowDisabled" ? Number(0.5) : Number(1);
         _loc3_.clear();
         _loc3_.beginFill(getStyle("symbolColor"),_loc4_);
         _loc3_.moveTo(0,0);
         _loc3_.lineTo(param1,0);
         _loc3_.lineTo(param1 / 2,param2);
         _loc3_.lineTo(0,0);
         _loc3_.endFill();
      }
   }
}
