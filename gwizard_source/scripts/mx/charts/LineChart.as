package mx.charts
{
   import flash.filters.DropShadowFilter;
   import mx.charts.chartClasses.CartesianChart;
   import mx.charts.chartClasses.IAxis;
   import mx.charts.renderers.LineRenderer;
   import mx.charts.styles.HaloDefaults;
   import mx.core.ClassFactory;
   import mx.core.IFlexModuleFactory;
   import mx.core.mx_internal;
   import mx.graphics.SolidColor;
   import mx.graphics.SolidColorStroke;
   import mx.graphics.Stroke;
   import mx.styles.CSSStyleDeclaration;
   
   use namespace mx_internal;
   
   public class LineChart extends CartesianChart
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _moduleFactoryInitialized:Boolean = false;
      
      public function LineChart()
      {
         super();
         LinearAxis(horizontalAxis).autoAdjust = false;
         seriesFilters = [new DropShadowFilter()];
      }
      
      override public function set horizontalAxis(param1:IAxis) : void
      {
         if(param1 is CategoryAxis)
         {
            CategoryAxis(param1).padding = 0;
         }
         super.horizontalAxis = param1;
      }
      
      private function initStyles() : Boolean
      {
         var styleName:String = null;
         var o:CSSStyleDeclaration = null;
         var f:Function = null;
         HaloDefaults.init(styleManager);
         var lineChartSeriesStyles:Array = [];
         var lineChartStyle:CSSStyleDeclaration = styleManager.getStyleDeclaration("mx.charts.LineChart");
         lineChartStyle.setStyle("chartSeriesStyles",lineChartSeriesStyles);
         lineChartStyle.setStyle("fill",new SolidColor(16777215,0));
         lineChartStyle.setStyle("calloutStroke",new SolidColorStroke(8947848,2));
         lineChartStyle.setStyle("horizontalAxisStyleNames",["hangingCategoryAxis"]);
         lineChartStyle.setStyle("verticalAxisStyleNames",["blockNumericAxis"]);
         var n:int = HaloDefaults.defaultColors.length;
         var i:int = 0;
         while(i < n)
         {
            styleName = "haloLineSeries" + i;
            lineChartSeriesStyles[i] = styleName;
            o = HaloDefaults.createSelector("." + styleName,styleManager);
            f = function(param1:CSSStyleDeclaration, param2:Stroke):void
            {
               var o:CSSStyleDeclaration = param1;
               var stroke:Stroke = param2;
               o.defaultFactory = function():void
               {
                  this.lineStroke = stroke;
                  this.stroke = stroke;
                  this.lineSegmentRenderer = new ClassFactory(LineRenderer);
               };
            };
            f(o,new Stroke(HaloDefaults.defaultColors[i],3,1));
            i++;
         }
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
   }
}
