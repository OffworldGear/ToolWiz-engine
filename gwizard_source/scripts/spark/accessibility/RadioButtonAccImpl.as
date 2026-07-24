package spark.accessibility
{
   import mx.accessibility.AccConst;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import spark.components.RadioButton;
   import spark.components.RadioButtonGroup;
   
   use namespace mx_internal;
   
   public class RadioButtonAccImpl extends CheckBoxAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function RadioButtonAccImpl(param1:UIComponent)
      {
         super(param1);
         role = AccConst.ROLE_SYSTEM_RADIOBUTTON;
      }
      
      public static function enableAccessibility() : void
      {
         RadioButton.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new RadioButtonAccImpl(param1);
      }
      
      override protected function getName(param1:uint) : String
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:RadioButton = null;
         var _loc2_:String = RadioButton(master).label;
         var _loc3_:RadioButtonGroup = RadioButton(master).group;
         if(_loc3_)
         {
            _loc4_ = 0;
            _loc5_ = _loc3_.numRadioButtons;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if((_loc7_ = _loc3_.getRadioButtonAt(_loc6_)) === master)
               {
                  _loc4_ = _loc6_ + 1;
                  break;
               }
               _loc6_++;
            }
            _loc2_ += " " + _loc4_ + " of " + _loc5_;
         }
         return _loc2_;
      }
   }
}
