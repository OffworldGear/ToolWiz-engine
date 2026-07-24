package mx.containers
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class TitleWindow extends Panel
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
       
      
      public function TitleWindow()
      {
         super();
      }
      
      public function get showCloseButton() : Boolean
      {
         return mx_internal::_showCloseButton;
      }
      
      public function set showCloseButton(param1:Boolean) : void
      {
         _showCloseButton = param1;
      }
      
      override protected function initializeAccessibility() : void
      {
         if(TitleWindow.createAccessibilityImplementation != null)
         {
            TitleWindow.createAccessibilityImplementation(this);
         }
      }
   }
}
