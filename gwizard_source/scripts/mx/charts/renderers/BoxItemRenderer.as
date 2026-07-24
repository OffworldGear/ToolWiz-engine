package mx.charts.renderers
{
   import flash.display.Graphics;
   import flash.geom.Rectangle;
   import mx.charts.ChartItem;
   import mx.charts.chartClasses.GraphicsUtilities;
   import mx.core.IDataRenderer;
   import mx.core.mx_internal;
   import mx.graphics.IFill;
   import mx.graphics.IStroke;
   import mx.graphics.SolidColor;
   import mx.skins.ProgrammaticSkin;
   import mx.utils.ColorUtil;
   
   use namespace mx_internal;
   
   public class BoxItemRenderer extends ProgrammaticSkin implements IDataRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _data:Object;
      
      public function BoxItemRenderer()
      {
         super();
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         if(this._data == param1)
         {
            return;
         }
         this._data = param1;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:IFill = null;
         var _loc5_:uint = 0;
         super.updateDisplayList(param1,param2);
         var _loc4_:String = "";
         if(this._data is ChartItem && this._data.hasOwnProperty("fill"))
         {
            _loc4_ = this._data.currentState;
            _loc3_ = this._data.fill;
         }
         else
         {
            _loc3_ = GraphicsUtilities.fillFromStyle(getStyle("fill"));
         }
         var _loc6_:Number = 0;
         switch(_loc4_)
         {
            case ChartItem.FOCUSED:
            case ChartItem.ROLLOVER:
               if(styleManager.isValidStyleValue(getStyle("itemRollOverColor")))
               {
                  _loc5_ = getStyle("itemRollOverColor");
               }
               else
               {
                  _loc5_ = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(_loc3_),-20);
               }
               _loc3_ = new SolidColor(_loc5_);
               if(!(_loc6_ = getStyle("adjustedRadius")))
               {
                  _loc6_ = 0;
               }
               break;
            case ChartItem.DISABLED:
               if(styleManager.isValidStyleValue(getStyle("itemDisabledColor")))
               {
                  _loc5_ = getStyle("itemDisabledColor");
               }
               else
               {
                  _loc5_ = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(_loc3_),20);
               }
               _loc3_ = new SolidColor(GraphicsUtilities.colorFromFill(_loc5_));
               break;
            case ChartItem.FOCUSEDSELECTED:
            case ChartItem.SELECTED:
               if(styleManager.isValidStyleValue(getStyle("itemSelectionColor")))
               {
                  _loc5_ = getStyle("itemSelectionColor");
               }
               else
               {
                  _loc5_ = ColorUtil.adjustBrightness2(GraphicsUtilities.colorFromFill(_loc3_),-30);
               }
               _loc3_ = new SolidColor(_loc5_);
               if(!(_loc6_ = getStyle("adjustedRadius")))
               {
                  _loc6_ = 0;
               }
         }
         var _loc8_:Number = !!(_loc7_ = getStyle("stroke")) ? Number(_loc7_.weight / 2) : Number(0);
         var _loc9_:Rectangle = new Rectangle(_loc8_ - _loc6_,_loc8_ - _loc6_,width - 2 * _loc8_ + _loc6_ * 2,height - 2 * _loc8_ + _loc6_ * 2);
         var _loc10_:Graphics;
         (_loc10_ = graphics).clear();
         _loc10_.moveTo(_loc9_.left,_loc9_.top);
         if(_loc7_)
         {
            _loc7_.apply(_loc10_,null,null);
         }
         if(_loc3_)
         {
            _loc3_.begin(_loc10_,_loc9_,null);
         }
         _loc10_.lineTo(_loc9_.right,_loc9_.top);
         _loc10_.lineTo(_loc9_.right,_loc9_.bottom);
         _loc10_.lineTo(_loc9_.left,_loc9_.bottom);
         _loc10_.lineTo(_loc9_.left,_loc9_.top);
         if(_loc3_)
         {
            _loc3_.end(_loc10_);
         }
      }
   }
}
