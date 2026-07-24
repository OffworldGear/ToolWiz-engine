package spark.components
{
   import mx.core.mx_internal;
   import spark.components.supportClasses.ToggleButtonBase;
   
   use namespace mx_internal;
   
   public class CheckBox extends ToggleButtonBase
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      mx_internal static var createAccessibilityImplementation:Function;
      
      private static const focusExclusions:Array = ["labelDisplay"];
       
      
      public function CheckBox()
      {
         super();
      }
      
      override public function get suggestedFocusSkinExclusions() : Array
      {
         return focusExclusions;
      }
      
      override protected function initializeAccessibility() : void
      {
         if(CheckBox.createAccessibilityImplementation != null)
         {
            CheckBox.createAccessibilityImplementation(this);
         }
      }
   }
}
