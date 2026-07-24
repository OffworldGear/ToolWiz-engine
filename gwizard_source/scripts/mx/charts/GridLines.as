package mx.charts
{
   import flash.display.Graphics;
   import flash.geom.Rectangle;
   import mx.charts.chartClasses.CartesianChart;
   import mx.charts.chartClasses.ChartElement;
   import mx.charts.chartClasses.ChartState;
   import mx.charts.chartClasses.GraphicsUtilities;
   import mx.charts.chartClasses.IAxisRenderer;
   import mx.charts.styles.HaloDefaults;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.graphics.IStroke;
   import mx.graphics.SolidColorStroke;
   import mx.styles.CSSStyleDeclaration;
   
   use namespace mx_internal;
   
   public class GridLines extends ChartElement
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      public function GridLines()
      {
         super();
      }
      
      private function initStyles() : Boolean
      {
         HaloDefaults.init(styleManager);
         var _loc1_:CSSStyleDeclaration = styleManager.getStyleDeclaration("mx.charts.GridLines");
         _loc1_.setStyle("horizontalOriginStroke",new SolidColorStroke(11583952,1));
         _loc1_.setStyle("horizontalStroke",new SolidColorStroke(15658734,0));
         _loc1_.setStyle("verticalOriginStroke",new SolidColorStroke(11583952,1));
         _loc1_.setStyle("verticalStroke",new SolidColorStroke(15658734,0));
         var _loc2_:CSSStyleDeclaration = styleManager.getStyleDeclaration(".horizontalGridLines");
         _loc2_.setStyle("horizontalFill",null);
         _loc2_.setStyle("verticalFill",null);
         return true;
      }
      
      override public function set moduleFactory(param1:IFlexModuleFactory) : void
      {
         super.moduleFactory = param1;
         if(this._moduleFactoryInitialized)
         {
            return;
         }
         this._moduleFactoryInitialized = true;
         this.initStyles();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:IStroke = null;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         var _loc10_:Array = null;
         var _loc11_:Rectangle = null;
         var _loc12_:IStroke = null;
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:int = 0;
         var _loc20_:IAxisRenderer = null;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:IAxisRenderer = null;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Array = null;
         var _loc29_:Number = NaN;
         super.updateDisplayList(param1,param2);
         if(!chart || chart.chartState == ChartState.PREPARING_TO_HIDE_DATA || chart.chartState == ChartState.HIDING_DATA)
         {
            return;
         }
         var _loc16_:Graphics;
         (_loc16_ = graphics).clear();
         var _loc17_:String;
         if((_loc17_ = getStyle("gridDirection")) == "horizontal" || _loc17_ == "both")
         {
            _loc5_ = getStyle("horizontalStroke");
            if((_loc6_ = Math.max(1,getStyle("horizontalChangeCount"))) * 0 != 0 || _loc6_ <= 1)
            {
               _loc6_ = 1;
            }
            if(!CartesianChart(chart).verticalAxisRenderer)
            {
               if(!(_loc20_ = CartesianChart(chart).getLeftMostRenderer()))
               {
                  _loc20_ = CartesianChart(chart).getRightMostRenderer();
               }
            }
            else
            {
               _loc20_ = CartesianChart(chart).verticalAxisRenderer;
            }
            _loc7_ = _loc20_.ticks;
            if(getStyle("horizontalTickAligned") == false)
            {
               _loc3_ = _loc7_.length;
               _loc8_ = [];
               _loc15_ = _loc3_;
               _loc21_ = 1;
               while(_loc21_ < _loc15_)
               {
                  _loc8_[_loc21_ - 1] = (_loc7_[_loc21_] + _loc7_[_loc21_ - 1]) / 2;
                  _loc21_++;
               }
            }
            else
            {
               _loc8_ = _loc7_;
            }
            _loc13_ = false;
            _loc14_ = false;
            if(_loc8_[0] != 0)
            {
               _loc13_ = true;
               _loc8_.unshift(0);
            }
            if(_loc8_[_loc8_.length - 1] != 1)
            {
               _loc14_ = true;
               _loc8_.push(1);
            }
            _loc9_ = param2;
            _loc10_ = [getStyle("horizontalFill"),getStyle("horizontalAlternateFill")];
            _loc3_ = _loc8_.length;
            if(_loc8_[_loc3_ - 1] < 1)
            {
               if((_loc4_ = _loc10_[1]) != null)
               {
                  _loc16_.lineStyle(0,0,0);
                  GraphicsUtilities.fillRect(_loc16_,0,_loc8_[_loc3_ - 1] * _loc9_,param1,param2,_loc4_);
               }
            }
            _loc15_ = _loc8_.length;
            _loc21_ = 0;
            while(_loc21_ < _loc15_)
            {
               _loc22_ = _loc3_ - 1 - _loc21_;
               _loc4_ = _loc10_[_loc21_ / _loc6_ % 2];
               _loc23_ = _loc8_[_loc22_] * _loc9_;
               _loc24_ = _loc8_[Math.max(0,_loc22_ - _loc6_)] * _loc9_;
               _loc11_ = new Rectangle(0,_loc24_,param1,_loc23_ - _loc24_);
               if(_loc4_ != null)
               {
                  _loc16_.lineStyle(0,0,0);
                  GraphicsUtilities.fillRect(_loc16_,_loc11_.left,_loc11_.top,_loc11_.right,_loc11_.bottom,_loc4_);
               }
               if(_loc5_ && _loc11_.bottom >= -1)
               {
                  if(!(_loc13_ && _loc22_ == 0))
                  {
                     if(!(_loc14_ && _loc22_ == _loc8_.length - 1))
                     {
                        _loc5_.apply(_loc16_,null,null);
                        _loc16_.moveTo(_loc11_.left,_loc11_.bottom);
                        _loc16_.lineTo(_loc11_.right,_loc11_.bottom);
                     }
                  }
               }
               _loc21_ += _loc6_;
            }
         }
         if(_loc17_ == "vertical" || _loc17_ == "both")
         {
            _loc5_ = getStyle("verticalStroke");
            _loc6_ = Math.max(1,getStyle("verticalChangeCount"));
            if(isNaN(_loc6_) || _loc6_ <= 1)
            {
               _loc6_ = 1;
            }
            if(!CartesianChart(chart).horizontalAxisRenderer)
            {
               if(!(_loc25_ = CartesianChart(chart).getBottomMostRenderer()))
               {
                  _loc25_ = CartesianChart(chart).getTopMostRenderer();
               }
            }
            else
            {
               _loc25_ = CartesianChart(chart).horizontalAxisRenderer;
            }
            _loc7_ = _loc25_.ticks.concat();
            if(getStyle("verticalTickAligned") == false)
            {
               _loc3_ = _loc7_.length;
               _loc8_ = [];
               _loc15_ = _loc3_;
               _loc21_ = 1;
               while(_loc21_ < _loc15_)
               {
                  _loc8_[_loc21_ - 1] = (_loc7_[_loc21_] + _loc7_[_loc21_ - 1]) / 2;
                  _loc21_++;
               }
            }
            else
            {
               _loc8_ = _loc7_;
            }
            _loc13_ = false;
            _loc14_ = false;
            if(_loc8_[0] != 0)
            {
               _loc13_ = true;
               _loc8_.unshift(0);
            }
            if(_loc8_[_loc8_.length - 1] != 1)
            {
               _loc14_ = true;
               _loc8_.push(1);
            }
            _loc9_ = param1;
            _loc10_ = [getStyle("verticalFill"),getStyle("verticalAlternateFill")];
            _loc15_ = _loc8_.length;
            _loc21_ = 0;
            while(_loc21_ < _loc15_)
            {
               _loc4_ = _loc10_[_loc21_ / _loc6_ % 2];
               _loc26_ = _loc8_[_loc21_] * _loc9_;
               _loc27_ = _loc8_[Math.min(_loc8_.length - 1,_loc21_ + _loc6_)] * _loc9_;
               _loc11_ = new Rectangle(_loc26_,0,_loc27_ - _loc26_,param2);
               if(_loc4_ != null)
               {
                  _loc16_.lineStyle(0,0,0);
                  GraphicsUtilities.fillRect(_loc16_,_loc11_.left,_loc11_.top,_loc11_.right,_loc11_.bottom,_loc4_);
               }
               if(_loc5_)
               {
                  if(!(_loc13_ && _loc21_ == 0))
                  {
                     if(!(_loc14_ && _loc21_ == _loc8_.length - 1))
                     {
                        _loc5_.apply(_loc16_,null,null);
                        _loc16_.moveTo(_loc11_.left,_loc11_.top);
                        _loc16_.lineTo(_loc11_.left,_loc11_.bottom);
                     }
                  }
               }
               _loc21_ += _loc6_;
            }
         }
         var _loc18_:Object = getStyle("horizontalShowOrigin");
         var _loc19_:Object;
         if((_loc19_ = getStyle("verticalShowOrigin")) || _loc18_)
         {
            _loc28_ = [{
               "xOrigin":0,
               "yOrigin":0
            }];
            _loc29_ = 0.5;
            dataTransform.transformCache(_loc28_,"xOrigin","x","yOrigin","y");
            if(_loc18_ && _loc28_[0].y > 0 && _loc28_[0].y < param2)
            {
               (_loc12_ = getStyle("horizontalOriginStroke")).apply(_loc16_,null,null);
               _loc16_.moveTo(0,_loc28_[0].y - _loc29_ / 2);
               _loc16_.lineTo(mx_internal::$width,_loc28_[0].y - _loc29_ / 2);
            }
            if(_loc19_ && _loc28_[0].x > 0 && _loc28_[0].x < param1)
            {
               (_loc12_ = getStyle("verticalOriginStroke")).apply(_loc16_,null,null);
               _loc16_.moveTo(_loc28_[0].x - _loc29_ / 2,0);
               _loc16_.lineTo(_loc28_[0].x - _loc29_ / 2,mx_internal::$height);
            }
         }
      }
      
      override public function mappingChanged() : void
      {
         invalidateDisplayList();
      }
      
      override public function chartStateChanged(param1:uint, param2:uint) : void
      {
         invalidateDisplayList();
      }
   }
}
