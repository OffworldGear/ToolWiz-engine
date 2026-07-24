package mx.charts.styles
{
   import mx.core.mx_internal;
   import mx.graphics.IFill;
   import mx.graphics.IStroke;
   import mx.graphics.SolidColor;
   import mx.graphics.Stroke;
   import mx.styles.CSSStyleDeclaration;
   import mx.styles.IStyleManager2;
   
   use namespace mx_internal;
   
   public class HaloDefaults
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      private static var inited:Boolean;
      
      mx_internal static var chartBaseChartSeriesStyles:Array;
      
      mx_internal static var defaultColors:Array = [14976769,10861646,1807833,13290142,6722480,15752743,8835556,15006112,16766226,7712768,418480,15591622,13382400,13754343,5428426,12968029,15188340,16775063,12973711,12448230,10393725,15440013,9554405,9690186,16759040,10402765,38807,897730];
      
      mx_internal static var defaultFills:Array = [];
      
      mx_internal static var pointStroke:IStroke;
      
      mx_internal static var emptyStroke:IStroke;
       
      
      public function HaloDefaults()
      {
         super();
      }
      
      public static function createSelector(param1:String, param2:IStyleManager2) : CSSStyleDeclaration
      {
         var _loc3_:CSSStyleDeclaration = param2.getStyleDeclaration(param1);
         if(!_loc3_)
         {
            _loc3_ = new CSSStyleDeclaration();
            param2.setStyleDeclaration(param1,_loc3_,false);
         }
         return _loc3_;
      }
      
      public static function init(param1:IStyleManager2) : void
      {
         var f:Function = null;
         var styleName:String = null;
         var o:CSSStyleDeclaration = null;
         var styleManager:IStyleManager2 = param1;
         if(inited)
         {
            return;
         }
         var seriesStyleCount:int = mx_internal::defaultColors.length;
         var i:int = 0;
         while(i < seriesStyleCount)
         {
            mx_internal::defaultFills[i] = new SolidColor(mx_internal::defaultColors[i]);
            i++;
         }
         pointStroke = new Stroke(0,0,0.5);
         emptyStroke = new Stroke(0,0,0);
         chartBaseChartSeriesStyles = [];
         i = 0;
         while(i < seriesStyleCount)
         {
            styleName = "haloSeries" + i;
            mx_internal::chartBaseChartSeriesStyles[i] = styleName;
            o = HaloDefaults.createSelector("." + styleName,styleManager);
            f = function(param1:CSSStyleDeclaration, param2:IFill, param3:IStroke):void
            {
               var o:CSSStyleDeclaration = param1;
               var defaultFill:IFill = param2;
               var defaultStroke:IStroke = param3;
               o.defaultFactory = function():void
               {
                  this.fill = defaultFill;
                  this.areaFill = defaultFill;
                  this.areaStroke = mx_internal::emptyStroke;
                  this.lineStroke = defaultStroke;
               };
            };
            f(o,HaloDefaults.defaultFills[i],new Stroke(mx_internal::defaultColors[i],3,1));
            i++;
         }
      }
   }
}
