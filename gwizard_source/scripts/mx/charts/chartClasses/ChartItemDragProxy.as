package mx.charts.chartClasses
{
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import mx.charts.ChartItem;
   import mx.core.IDataRenderer;
   import mx.core.IFlexDisplayObject;
   import mx.core.LayoutDirection;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ChartItemDragProxy extends UIComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function ChartItemDragProxy()
      {
         super();
      }
      
      override protected function createChildren() : void
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:ChartItem = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Class = null;
         super.createChildren();
         var _loc1_:Array = ChartBase(owner).selectedChartItems;
         var _loc2_:int = _loc1_.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc4_ = _loc1_[_loc3_].itemRenderer)
            {
               _loc5_ = _loc1_[_loc3_].clone();
               _loc6_ = getQualifiedClassName(_loc5_.itemRenderer);
               (_loc7_ = new (_loc8_ = getDefinitionByName(_loc6_) as Class)()).data = IDataRenderer(_loc5_.itemRenderer).data;
               if((_loc5_.itemRenderer as Object).hasOwnProperty("styleName"))
               {
                  _loc7_.styleName = Object(_loc5_.itemRenderer).styleName;
               }
               _loc5_.itemRenderer = IFlexDisplayObject(_loc7_);
               addChild(DisplayObject(_loc5_.itemRenderer));
               _loc5_.itemRenderer.setActualSize(_loc4_.width,_loc4_.height);
               _loc5_.itemRenderer.x = _loc4_.x;
               _loc5_.itemRenderer.y = _loc4_.y;
               measuredHeight = Math.max(measuredHeight,_loc5_.itemRenderer.y + _loc5_.itemRenderer.height);
               measuredWidth = Math.max(measuredWidth,_loc5_.itemRenderer.x + _loc5_.itemRenderer.width);
               if(ChartBase(owner).layoutDirection == LayoutDirection.RTL)
               {
                  layoutDirection = LayoutDirection.RTL;
               }
            }
            _loc3_++;
         }
         invalidateDisplayList();
      }
   }
}
