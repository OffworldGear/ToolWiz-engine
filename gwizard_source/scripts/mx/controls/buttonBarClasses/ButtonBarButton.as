package mx.controls.buttonBarClasses
{
   import mx.controls.Button;
   import mx.core.UITextFormat;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ButtonBarButton extends Button
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var inLayoutContents:Boolean = false;
      
      public function ButtonBarButton()
      {
         super();
      }
      
      override public function determineTextFormatFromStyles() : UITextFormat
      {
         if(this.inLayoutContents && selected)
         {
            return textField.getUITextFormat();
         }
         return super.determineTextFormatFromStyles();
      }
      
      override mx_internal function layoutContents(param1:Number, param2:Number, param3:Boolean) : void
      {
         this.inLayoutContents = true;
         super.layoutContents(param1,param2,param3);
         this.inLayoutContents = false;
      }
   }
}
