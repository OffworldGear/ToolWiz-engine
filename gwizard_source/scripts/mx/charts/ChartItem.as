package mx.charts
{
   import flash.events.EventDispatcher;
   import mx.charts.chartClasses.IChartElement;
   import mx.core.IFlexDisplayObject;
   import mx.core.IProgrammaticSkin;
   import mx.core.IUIComponent;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ChartItem extends EventDispatcher
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
      
      public static const FOCUSED:String = "focused";
      
      public static const SELECTED:String = "selected";
      
      public static const FOCUSEDSELECTED:String = "focusedSelected";
      
      public static const ROLLOVER:String = "rollOver";
      
      public static const DISABLED:String = "disabled";
      
      public static const NONE:String = "none";
       
      
      private var _currentState:String = "";
      
      public var element:IChartElement;
      
      public var index:int;
      
      public var item:Object;
      
      public var itemRenderer:IFlexDisplayObject;
      
      public function ChartItem(param1:IChartElement = null, param2:Object = null, param3:uint = 0)
      {
         super();
         this.element = param1;
         this.item = param2;
         this.index = param3;
         this._currentState = ChartItem.NONE;
      }
      
      public function get currentState() : String
      {
         return this._currentState;
      }
      
      public function set currentState(param1:String) : void
      {
         if(this._currentState != param1)
         {
            this._currentState = param1;
            if(this.itemRenderer && (this.itemRenderer is IProgrammaticSkin || this.itemRenderer is IUIComponent))
            {
               (this.itemRenderer as Object).invalidateDisplayList();
            }
         }
      }
      
      public function clone() : ChartItem
      {
         var _loc1_:ChartItem = new ChartItem(this.element,this.item,this.index);
         _loc1_.itemRenderer = this.itemRenderer;
         return _loc1_;
      }
   }
}
