package mx.charts.renderers
{
   import mx.charts.chartClasses.GraphicsUtilities;
   import mx.core.IDataRenderer;
   import mx.core.mx_internal;
   import mx.graphics.IStroke;
   import mx.skins.ProgrammaticSkin;
   
   use namespace mx_internal;
   
   public class LineRenderer extends ProgrammaticSkin implements IDataRenderer
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var _data:Object;
      
      public function LineRenderer()
      {
         super();
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         invalidateDisplayList();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         var _loc3_:IStroke = getStyle("lineStroke");
         var _loc4_:String = getStyle("form");
         graphics.clear();
         GraphicsUtilities.drawPolyLine(graphics,this._data.items,this._data.start,this._data.end + 1,"x","y",_loc3_,_loc4_);
      }
   }
}
