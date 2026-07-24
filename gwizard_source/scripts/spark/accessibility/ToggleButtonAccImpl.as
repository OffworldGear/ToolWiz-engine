package spark.accessibility
{
   import mx.accessibility.AccConst;
   import mx.accessibility.AccImpl;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import spark.components.supportClasses.ToggleButtonBase;
   
   use namespace mx_internal;
   
   public class ToggleButtonAccImpl extends ButtonBaseAccImpl
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function ToggleButtonAccImpl(param1:UIComponent)
      {
         super(param1);
      }
      
      public static function enableAccessibility() : void
      {
         ToggleButtonBase.createAccessibilityImplementation = mx_internal::createAccessibilityImplementation;
      }
      
      mx_internal static function createAccessibilityImplementation(param1:UIComponent) : void
      {
         param1.accessibilityImplementation = new ToggleButtonAccImpl(param1);
      }
      
      override public function get_accName(param1:uint) : String
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         if(master.accessibilityName && master.accessibilityName.indexOf(",") != -1)
         {
            _loc2_ = AccImpl.getFormName(master);
            _loc3_ = master.accessibilityName.split(",");
            _loc2_ += " " + (!!ToggleButtonBase(master).selected ? _loc3_[1] : _loc3_[0]);
         }
         else
         {
            _loc2_ = super.get_accName(0);
         }
         return _loc2_;
      }
      
      override public function get_accState(param1:uint) : uint
      {
         var _loc2_:uint = getState(param1);
         if(ToggleButtonBase(master).selected && (!master.accessibilityName || master.accessibilityName.indexOf(",") == -1))
         {
            _loc2_ |= AccConst.STATE_SYSTEM_PRESSED;
         }
         return _loc2_;
      }
   }
}
