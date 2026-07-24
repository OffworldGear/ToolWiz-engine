package mx.charts.chartClasses
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.geom.Rectangle;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mx.charts.HitData;
   import mx.core.IDataRenderer;
   import mx.core.IFlexModuleFactory;
   import mx.core.IUITextField;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   import mx.graphics.IFill;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   
   use namespace mx_internal;
   
   public class DataTip extends UIComponent implements IDataRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static const HEX_DIGITS:String = "0123456789ABCDEF";
      
      public static var maxTipWidth:Number = 300;
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      private var _label:IUITextField;
      
      private var _format:TextFormat;
      
      private var _hitData:HitData;
      
      private var _labelWidth:Number;
      
      private var _labelHeight:Number;
      
      private var _shadowFill:IFill;
      
      private var stroke:SolidColorStroke;
      
      public function DataTip()
      {
         this._shadowFill = IFill(new SolidColor(11184810,0.55));
         this.stroke = new SolidColorStroke(0,0,1);
         super();
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function get data() : Object
      {
         return this._hitData;
      }
      
      public function set data(param1:Object) : void
      {
         this._hitData = HitData(param1);
         this.stroke = new SolidColorStroke(this._hitData.contextColor,0,100);
         this.setText(this._hitData.displayText);
         invalidateDisplayList();
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this._moduleFactoryInitialized)
         {
            return;
         }
         this._moduleFactoryInitialized = true;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         if(!this._label)
         {
            this._label = IUITextField(createInFontContext(UITextField));
            this._label.x = getStyle("paddingLeft");
            this._label.y = getStyle("paddingTop");
            this._label.autoSize = TextFieldAutoSize.LEFT;
            this._label.selectable = false;
            this._label.multiline = true;
            addChild(DisplayObject(this._label));
         }
      }
      
      override protected function measure() : void
      {
         super.measure();
         var _loc1_:Rectangle = new Rectangle(1,1,0,0);
         var _loc2_:Number = _loc1_.left + getStyle("paddingLeft");
         var _loc3_:Number = _loc1_.top + getStyle("paddingTop");
         var _loc4_:Number = _loc1_.right + getStyle("paddingRight");
         var _loc5_:Number = _loc1_.bottom + getStyle("paddingBottom");
         var _loc6_:Number = _loc2_ + _loc4_;
         var _loc7_:Number = _loc3_ + _loc5_;
         this._label.wordWrap = false;
         if(this._label.textWidth + _loc6_ > DataTip.maxTipWidth)
         {
            this._label.width = DataTip.maxTipWidth - _loc6_;
            this._label.wordWrap = true;
            this._label.width = this._label.textWidth + _loc6_;
         }
         this._labelWidth = this._label.width + _loc6_;
         this._labelHeight = this._label.height + _loc7_;
         measuredWidth = this._labelWidth + 6;
         measuredHeight = this._labelHeight + 6;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         var _loc3_:Graphics = graphics;
         _loc3_.clear();
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         _loc3_.moveTo(measuredWidth,2);
         this._shadowFill.begin(_loc3_,new Rectangle(_loc4_,_loc5_,measuredWidth,measuredHeight),null);
         _loc3_.lineTo(measuredWidth + 2,2);
         _loc3_.lineTo(measuredWidth + 2,measuredHeight + 2);
         _loc3_.lineTo(2,measuredHeight + 2);
         _loc3_.lineTo(2,measuredHeight);
         _loc3_.lineTo(measuredWidth - 2,measuredHeight - 2);
         _loc3_.lineTo(measuredWidth - 2,2);
         this._shadowFill.end(_loc3_);
         var _loc6_:IFill = IFill(new SolidColor(getStyle("backgroundColor"),0.8));
         GraphicsUtilities.fillRect(_loc3_,_loc4_,_loc5_,measuredWidth,measuredHeight,_loc6_,this.stroke);
         this._label.x = _loc4_ + getStyle("paddingLeft");
         this._label.y = _loc5_ + getStyle("paddingTop");
      }
      
      private function setText(param1:String) : void
      {
         var _loc2_:TextFormat = this._label.getTextFormat();
         _loc2_.leftMargin = 0;
         _loc2_.rightMargin = 0;
         this._label.defaultTextFormat = _loc2_;
         this._label.htmlText = param1;
         invalidateSize();
      }
      
      private function decToColor(param1:Number) : String
      {
         var _loc2_:String = "#";
         var _loc3_:int = 5;
         while(_loc3_ >= 0)
         {
            _loc2_ += HEX_DIGITS.charAt(param1 >> _loc3_ * 4 & 15);
            _loc3_--;
         }
         return _loc2_;
      }
   }
}
