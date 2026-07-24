package mx.charts.chartClasses
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import mx.charts.AxisLabel;
   import mx.charts.AxisRenderer;
   import mx.core.FlexBitmap;
   import mx.core.IDataRenderer;
   import mx.core.IUITextField;
   import mx.core.LayoutDirection;
   import mx.core.UIComponent;
   import mx.core.UITextField;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ChartLabel extends UIComponent implements IDataRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var ORIGIN:Point = new Point(0,0);
      
      private static var X_UNIT:Point = new Point(1,0);
       
      
      private var _label:IUITextField;
      
      private var _bitmap:Bitmap;
      
      private var _capturedText:BitmapData;
      
      private var _text:String;
      
      private var _data:Object;
      
      public function ChartLabel()
      {
         super();
         this.includeInLayout = false;
         this.layoutDirection = LayoutDirection.LTR;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         if(param1 == this._data)
         {
            return;
         }
         this._data = param1;
         if(param1 is AxisLabel)
         {
            this._text = AxisLabel(param1).text;
         }
         else if(param1 is String)
         {
            this._text = String(param1);
         }
         this._label.text = this._text == null ? "" : this._text;
         this.invalidateSize();
         invalidateDisplayList();
      }
      
      override public function invalidateSize() : void
      {
         super.invalidateSize();
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         this._label = IUITextField(createInFontContext(UITextField));
         this._label.multiline = true;
         this._label.selectable = false;
         this._label.autoSize = "left";
         this._label.styleName = this;
         addChild(DisplayObject(this._label));
      }
      
      override protected function measure() : void
      {
         var _loc1_:Number = NaN;
         _loc1_ = rotation;
         if(parent && parent.rotation == 90)
         {
            rotation = -90;
         }
         this._label.validateNow();
         if(this._label.embedFonts)
         {
            measuredWidth = this._label.measuredWidth + 6;
            measuredHeight = this._label.measuredHeight + UITextField.TEXT_HEIGHT_PADDING;
         }
         else
         {
            measuredWidth = this._label.textWidth + 6;
            measuredHeight = this._label.textHeight + UITextField.TEXT_HEIGHT_PADDING;
         }
         rotation = _loc1_;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc6_:AxisRenderer = null;
         if(parent && parent is AxisRenderer && parent.rotation == 90 && this._label.embedFonts == true)
         {
            if((_loc6_ = AxisRenderer(parent)).getStyle("verticalAxisTitleAlignment") == "vertical" && _loc6_.layoutDirection == LayoutDirection.LTR || _loc6_.getStyle("verticalAxisTitleAlignment") == "flippedVertical" && _loc6_.layoutDirection == LayoutDirection.RTL)
            {
               this._label.rotation = 180;
               this._label.y += this._label.height;
               this._label.x += this._label.width;
            }
         }
         this._label.validateNow();
         this._label.setActualSize(param1,param2);
         var _loc5_:Boolean = true;
         if(this._label.embedFonts == false && param1 > 0 && param2 > 0)
         {
            _loc3_ = globalToLocal(X_UNIT);
            _loc4_ = globalToLocal(ORIGIN);
            _loc5_ = _loc3_.x - _loc4_.x == 1 && _loc3_.y - _loc4_.y == 0;
         }
         if(_loc5_)
         {
            if(this._bitmap)
            {
               removeChild(this._bitmap);
               this._bitmap = null;
            }
            this._label.visible = true;
         }
         else
         {
            this._label.visible = false;
            if(!this._capturedText || this._capturedText.width != param1 || this._capturedText.height != param2)
            {
               this._capturedText = new BitmapData(param1,param2);
               if(this._bitmap)
               {
                  removeChild(this._bitmap);
                  this._bitmap = null;
               }
            }
            if(!this._bitmap)
            {
               this._bitmap = new FlexBitmap(this._capturedText);
               this._bitmap.smoothing = true;
               addChild(this._bitmap);
            }
            this._capturedText.fillRect(new Rectangle(0,0,param1,param2),0);
            this._capturedText.draw(this._label);
            if(parent && parent.rotation == 90 && parent is AxisRenderer)
            {
               if((_loc6_ = AxisRenderer(parent)).getStyle("verticalAxisTitleAlignment") == "vertical" && _loc6_.layoutDirection == LayoutDirection.LTR || _loc6_.getStyle("verticalAxisTitleAlignment") == "flippedVertical" && _loc6_.layoutDirection == LayoutDirection.RTL)
               {
                  this._bitmap.rotation = 180;
                  this._bitmap.y = this._label.x + this._bitmap.height;
                  this._bitmap.x = this._label.y + this._bitmap.width;
               }
            }
         }
      }
   }
}
