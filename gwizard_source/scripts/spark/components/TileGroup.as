package spark.components
{
   import flash.events.Event;
   import mx.core.mx_internal;
   import spark.layouts.TileLayout;
   import spark.layouts.supportClasses.LayoutBase;
   
   use namespace mx_internal;
   
   public class TileGroup extends Group
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      public function TileGroup()
      {
         super();
         super.layout = new TileLayout();
      }
      
      private function get tileLayout() : TileLayout
      {
         return TileLayout(layout);
      }
      
      public function get columnAlign() : String
      {
         return this.tileLayout.columnAlign;
      }
      
      public function set columnAlign(param1:String) : void
      {
         this.tileLayout.columnAlign = param1;
      }
      
      [Bindable("propertyChange")]
      public function get columnCount() : int
      {
         return this.tileLayout.columnCount;
      }
      
      [Bindable("propertyChange")]
      public function get columnWidth() : int
      {
         return this.tileLayout.columnWidth;
      }
      
      public function set columnWidth(param1:int) : void
      {
         this.tileLayout.columnWidth = param1;
      }
      
      public function get horizontalAlign() : String
      {
         return this.tileLayout.horizontalAlign;
      }
      
      public function set horizontalAlign(param1:String) : void
      {
         this.tileLayout.horizontalAlign = param1;
      }
      
      [Bindable("propertyChange")]
      public function get horizontalGap() : int
      {
         return this.tileLayout.horizontalGap;
      }
      
      public function set horizontalGap(param1:int) : void
      {
         this.tileLayout.horizontalGap = param1;
      }
      
      public function get orientation() : String
      {
         return this.tileLayout.orientation;
      }
      
      public function set orientation(param1:String) : void
      {
         this.tileLayout.orientation = param1;
      }
      
      public function get paddingLeft() : Number
      {
         return this.tileLayout.paddingLeft;
      }
      
      public function set paddingLeft(param1:Number) : void
      {
         this.tileLayout.paddingLeft = param1;
      }
      
      public function get paddingRight() : Number
      {
         return this.tileLayout.paddingRight;
      }
      
      public function set paddingRight(param1:Number) : void
      {
         this.tileLayout.paddingRight = param1;
      }
      
      public function get paddingTop() : Number
      {
         return this.tileLayout.paddingTop;
      }
      
      public function set paddingTop(param1:Number) : void
      {
         this.tileLayout.paddingTop = param1;
      }
      
      public function get paddingBottom() : Number
      {
         return this.tileLayout.paddingBottom;
      }
      
      public function set paddingBottom(param1:Number) : void
      {
         this.tileLayout.paddingBottom = param1;
      }
      
      public function get requestedColumnCount() : int
      {
         return this.tileLayout.requestedColumnCount;
      }
      
      public function set requestedColumnCount(param1:int) : void
      {
         this.tileLayout.requestedColumnCount = param1;
      }
      
      public function get requestedRowCount() : int
      {
         return this.tileLayout.requestedRowCount;
      }
      
      public function set requestedRowCount(param1:int) : void
      {
         this.tileLayout.requestedRowCount = param1;
      }
      
      public function get rowAlign() : String
      {
         return this.tileLayout.rowAlign;
      }
      
      public function set rowAlign(param1:String) : void
      {
         this.tileLayout.rowAlign = param1;
      }
      
      [Bindable("propertyChange")]
      public function get rowCount() : int
      {
         return this.tileLayout.rowCount;
      }
      
      [Bindable("propertyChange")]
      public function get rowHeight() : int
      {
         return this.tileLayout.rowHeight;
      }
      
      public function set rowHeight(param1:int) : void
      {
         this.tileLayout.rowHeight = param1;
      }
      
      public function get verticalAlign() : String
      {
         return this.tileLayout.verticalAlign;
      }
      
      public function set verticalAlign(param1:String) : void
      {
         this.tileLayout.verticalAlign = param1;
      }
      
      [Bindable("propertyChange")]
      public function get verticalGap() : int
      {
         return this.tileLayout.verticalGap;
      }
      
      public function set verticalGap(param1:int) : void
      {
         this.tileLayout.verticalGap = param1;
      }
      
      override public function set layout(param1:LayoutBase) : void
      {
         throw new Error(resourceManager.getString("components","layoutReadOnly"));
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(param1 == "propertyChange")
         {
            if(!hasEventListener(param1))
            {
               this.tileLayout.addEventListener(param1,this.redispatchHandler);
            }
         }
         super.addEventListener(param1,param2,param3,param4,param5);
      }
      
      override public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         super.removeEventListener(param1,param2,param3);
         if(param1 == "propertyChange")
         {
            if(!hasEventListener(param1))
            {
               this.tileLayout.removeEventListener(param1,this.redispatchHandler);
            }
         }
      }
      
      private function redispatchHandler(param1:Event) : void
      {
         dispatchEvent(param1);
      }
   }
}
