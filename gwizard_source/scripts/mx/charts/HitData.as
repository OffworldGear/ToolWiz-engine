package mx.charts
{
   import mx.charts.chartClasses.GraphicsUtilities;
   import mx.charts.chartClasses.IChartElement;
   import mx.core.mx_internal;
   import mx.styles.IStyleClient;
   
   use namespace mx_internal;
   
   public class HitData
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public var chartItem:ChartItem;
      
      public var contextColor:uint = 0;
      
      public var dataTipFunction:Function;
      
      public var distance:Number;
      
      public var id:Number;
      
      public var item:Object;
      
      public var x:Number;
      
      public var y:Number;
      
      public function HitData(param1:Number, param2:Number, param3:Number, param4:Number, param5:ChartItem)
      {
         var _loc6_:Object = null;
         super();
         this.id = param1;
         this.distance = param2;
         this.x = param3;
         this.y = param4;
         this.chartItem = param5;
         this.item = param5.item;
         if(param5.element is IStyleClient)
         {
            _loc6_ = IStyleClient(param5.element).getStyle("fill");
            this.contextColor = GraphicsUtilities.colorFromFill(_loc6_);
         }
      }
      
      public function get displayText() : String
      {
         return this.dataTipFunction(this);
      }
      
      public function get element() : IChartElement
      {
         return this.chartItem.element;
      }
   }
}
