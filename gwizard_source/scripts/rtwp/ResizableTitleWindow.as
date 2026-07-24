package rtwp
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mx.core.UIComponent;
   import mx.events.SandboxMouseEvent;
   import spark.components.TitleWindow;
   
   public class ResizableTitleWindow extends TitleWindow
   {
       
      
      private var clickOffset:Point;
      
      [SkinPart("false",required="false")]
      public var resizeHandle:UIComponent;
      
      private var prevWidth:Number;
      
      private var prevHeight:Number;
      
      public function ResizableTitleWindow()
      {
         super();
      }
      
      override protected function partAdded(param1:String, param2:Object) : void
      {
         super.partAdded(param1,param2);
         if(param2 == this.resizeHandle)
         {
            this.resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN,this.resizeHandle_mouseDownHandler);
         }
      }
      
      override protected function partRemoved(param1:String, param2:Object) : void
      {
         if(param2 == this.resizeHandle)
         {
            this.resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN,this.resizeHandle_mouseDownHandler);
         }
         super.partRemoved(param1,param2);
      }
      
      protected function resizeHandle_mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = null;
         if(enabled && isPopUp && !this.clickOffset)
         {
            this.clickOffset = new Point(param1.stageX,param1.stageY);
            this.prevWidth = width;
            this.prevHeight = height;
            _loc2_ = systemManager.getSandboxRoot();
            _loc2_.addEventListener(MouseEvent.MOUSE_MOVE,this.resizeHandle_mouseMoveHandler,true);
            _loc2_.addEventListener(MouseEvent.MOUSE_UP,this.resizeHandle_mouseUpHandler,true);
            _loc2_.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.resizeHandle_mouseUpHandler);
         }
      }
      
      protected function resizeHandle_mouseMoveHandler(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         if(!this.clickOffset)
         {
            return;
         }
         width = this.prevWidth + (param1.stageX - this.clickOffset.x);
         height = this.prevHeight + (param1.stageY - this.clickOffset.y);
         param1.updateAfterEvent();
      }
      
      protected function resizeHandle_mouseUpHandler(param1:Event) : void
      {
         this.clickOffset = null;
         this.prevWidth = NaN;
         this.prevHeight = NaN;
         var _loc2_:DisplayObject = systemManager.getSandboxRoot();
         _loc2_.removeEventListener(MouseEvent.MOUSE_MOVE,this.resizeHandle_mouseMoveHandler,true);
         _loc2_.removeEventListener(MouseEvent.MOUSE_UP,this.resizeHandle_mouseUpHandler,true);
         _loc2_.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.resizeHandle_mouseUpHandler);
      }
   }
}
