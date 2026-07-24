package spark.primitives
{
   import flash.display.Graphics;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import mx.core.mx_internal;
   import mx.utils.MatrixUtil;
   import spark.primitives.supportClasses.FilledElement;
   
   use namespace mx_internal;
   
   public class Ellipse extends FilledElement
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function Ellipse()
      {
         super();
      }
      
      override protected function draw(param1:Graphics) : void
      {
         param1.drawEllipse(drawX,drawY,width,height);
      }
      
      override protected function transformWidthForLayout(param1:Number, param2:Number, param3:Boolean = true) : Number
      {
         if(param3 && hasComplexLayoutMatrix)
         {
            param1 = MatrixUtil.getEllipseBoundingBox(param1 / 2,param2 / 2,param1 / 2,param2 / 2,layoutFeatures.layoutMatrix).width;
         }
         return param1 + getStrokeExtents(param3).width;
      }
      
      override protected function transformHeightForLayout(param1:Number, param2:Number, param3:Boolean = true) : Number
      {
         if(param3 && hasComplexLayoutMatrix)
         {
            param2 = MatrixUtil.getEllipseBoundingBox(param1 / 2,param2 / 2,param1 / 2,param2 / 2,layoutFeatures.layoutMatrix).height;
         }
         return param2 + getStrokeExtents(param3).height;
      }
      
      override public function getBoundsXAtSize(param1:Number, param2:Number, param3:Boolean = true) : Number
      {
         var _loc4_:Rectangle = getStrokeExtents(param3);
         var _loc5_:Matrix;
         if(!(_loc5_ = getComplexMatrix(param3)))
         {
            return _loc4_.left + this.x;
         }
         if(!isNaN(param1))
         {
            param1 -= _loc4_.width;
         }
         if(!isNaN(param2))
         {
            param2 -= _loc4_.height;
         }
         var _loc6_:Point;
         if(!(_loc6_ = MatrixUtil.fitBounds(param1,param2,_loc5_,explicitWidth,explicitHeight,preferredWidthPreTransform(),preferredHeightPreTransform(),minWidth,minHeight,maxWidth,maxHeight)))
         {
            _loc6_ = new Point(minWidth,minHeight);
         }
         return _loc4_.left + MatrixUtil.getEllipseBoundingBox(_loc6_.x / 2,_loc6_.y / 2,_loc6_.x / 2,_loc6_.y / 2,_loc5_).x;
      }
      
      override public function getBoundsYAtSize(param1:Number, param2:Number, param3:Boolean = true) : Number
      {
         var _loc4_:Rectangle = getStrokeExtents(param3);
         var _loc5_:Matrix;
         if(!(_loc5_ = getComplexMatrix(param3)))
         {
            return _loc4_.top + this.y;
         }
         if(!isNaN(param1))
         {
            param1 -= _loc4_.width;
         }
         if(!isNaN(param2))
         {
            param2 -= _loc4_.height;
         }
         var _loc6_:Point;
         if(!(_loc6_ = MatrixUtil.fitBounds(param1,param2,_loc5_,explicitWidth,explicitHeight,preferredWidthPreTransform(),preferredHeightPreTransform(),minWidth,minHeight,maxWidth,maxHeight)))
         {
            _loc6_ = new Point(minWidth,minHeight);
         }
         return _loc4_.top + MatrixUtil.getEllipseBoundingBox(_loc6_.x / 2,_loc6_.y / 2,_loc6_.x / 2,_loc6_.y / 2,_loc5_).y;
      }
      
      override public function getLayoutBoundsX(param1:Boolean = true) : Number
      {
         var _loc2_:Number = getStrokeExtents(param1).left;
         if(param1 && hasComplexLayoutMatrix)
         {
            return _loc2_ + MatrixUtil.getEllipseBoundingBox(width / 2,height / 2,width / 2,height / 2,layoutFeatures.layoutMatrix).x;
         }
         return _loc2_ + this.x;
      }
      
      override public function getLayoutBoundsY(param1:Boolean = true) : Number
      {
         var _loc2_:Number = getStrokeExtents(param1).top;
         if(param1 && hasComplexLayoutMatrix)
         {
            return _loc2_ + MatrixUtil.getEllipseBoundingBox(width / 2,height / 2,width / 2,height / 2,layoutFeatures.layoutMatrix).y;
         }
         return _loc2_ + this.y;
      }
      
      private function getBoundingBox(param1:Number, param2:Number, param3:Matrix) : Rectangle
      {
         return MatrixUtil.getEllipseBoundingBox(0,0,param1 / 2,param2 / 2,param3);
      }
      
      override public function setLayoutBoundsSize(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         var _loc4_:Matrix;
         if(!(_loc4_ = getComplexMatrix(param3)))
         {
            super.setLayoutBoundsSize(param1,param2,param3);
            return;
         }
         this.setLayoutBoundsTransformed(param1,param2,_loc4_);
      }
      
      private function setLayoutBoundsTransformed(param1:Number, param2:Number, param3:Matrix) : void
      {
         var _loc6_:Point = null;
         var _loc7_:Point = null;
         var _loc8_:* = false;
         var _loc4_:Rectangle = getStrokeExtents(true);
         param1 -= _loc4_.width;
         param2 -= _loc4_.height;
         var _loc5_:Point;
         if(!(_loc5_ = this.fitLayoutBoundsIterative(param1,param2,param3)) && !isNaN(param1) && !isNaN(param2))
         {
            _loc6_ = this.fitLayoutBoundsIterative(NaN,param2,param3);
            _loc7_ = this.fitLayoutBoundsIterative(param1,NaN,param3);
            if(_loc6_ && this.getBoundingBox(_loc6_.x,_loc6_.y,param3).width > param1)
            {
               _loc6_ = null;
            }
            if(_loc7_ && this.getBoundingBox(_loc7_.x,_loc7_.y,param3).height > param2)
            {
               _loc7_ = null;
            }
            if(_loc6_ && _loc7_)
            {
               if(_loc8_ = _loc6_.x * _loc6_.y > _loc7_.x * _loc7_.y)
               {
                  _loc5_ = _loc6_;
               }
               else
               {
                  _loc5_ = _loc7_;
               }
            }
            else if(_loc6_)
            {
               _loc5_ = _loc6_;
            }
            else
            {
               _loc5_ = _loc7_;
            }
         }
         if(_loc5_)
         {
            setActualSize(_loc5_.x,_loc5_.y);
         }
         else
         {
            setActualSize(minWidth,minHeight);
         }
      }
      
      private function fitLayoutBoundsIterative(param1:Number, param2:Number, param3:Matrix) : Point
      {
         var _loc9_:Rectangle = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Point = null;
         var _loc4_:Number = this.preferredWidthPreTransform();
         var _loc5_:Number = this.preferredHeightPreTransform();
         var _loc6_:Number = MatrixUtil.transformBounds(_loc4_,_loc5_,param3).x;
         var _loc7_:Number = MatrixUtil.transformBounds(_loc4_,_loc5_,param3).y;
         if(isNaN(param1))
         {
            _loc6_ = NaN;
         }
         if(isNaN(param2))
         {
            _loc7_ = NaN;
         }
         var _loc8_:int = 0;
         while(_loc8_++ < 150)
         {
            _loc9_ = this.getBoundingBox(_loc4_,_loc5_,param3);
            _loc10_ = !!isNaN(param1) ? Number(0) : Number(param1 - _loc9_.width);
            _loc11_ = !!isNaN(param2) ? Number(0) : Number(param2 - _loc9_.height);
            if(Math.abs(_loc10_) < 0.1 && Math.abs(_loc11_) < 0.1)
            {
               return new Point(_loc4_,_loc5_);
            }
            _loc6_ += _loc10_ * 0.5;
            _loc7_ += _loc11_ * 0.5;
            if(!(_loc12_ = MatrixUtil.fitBounds(_loc6_,_loc7_,param3,explicitWidth,explicitHeight,preferredWidthPreTransform(),preferredHeightPreTransform(),minWidth,minHeight,maxWidth,maxHeight)))
            {
               break;
            }
            _loc4_ = _loc12_.x;
            _loc5_ = _loc12_.y;
         }
         return null;
      }
   }
}
