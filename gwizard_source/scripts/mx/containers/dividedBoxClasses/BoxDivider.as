package mx.containers.dividedBoxClasses
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.containers.DividedBox;
   import mx.containers.DividerState;
   import mx.core.ILayoutDirectionElement;
   import mx.core.UIComponent;
   import mx.core.mx_internal;
   import mx.events.SandboxMouseEvent;
   
   use namespace mx_internal;
   
   public class BoxDivider extends UIComponent
   {
      
      mx_internal static const VERSION:String = "4.6.0.23201";
       
      
      private var knob:DisplayObject;
      
      private var isMouseOver:Boolean = false;
      
      private var _state:String = "up";
      
      public function BoxDivider()
      {
         super();
         addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverHandler);
         addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutHandler);
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
      }
      
      override public function set x(param1:Number) : void
      {
         var _loc2_:Number = x;
         super.x = param1;
         if(!DividedBox(owner).isVertical())
         {
            DividedBox(owner).moveDivider(DividedBox(owner).getDividerIndex(this),param1 - _loc2_);
         }
      }
      
      override public function set y(param1:Number) : void
      {
         var _loc2_:Number = y;
         super.y = param1;
         if(DividedBox(owner).isVertical())
         {
            DividedBox(owner).moveDivider(DividedBox(owner).getDividerIndex(this),param1 - _loc2_);
         }
      }
      
      mx_internal function get state() : String
      {
         return this._state;
      }
      
      mx_internal function set state(param1:String) : void
      {
         this._state = param1;
         invalidateDisplayList();
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc7_:Class = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(isNaN(width) || isNaN(height))
         {
            return;
         }
         if(!parent)
         {
            return;
         }
         super.updateDisplayList(param1,param2);
         graphics.clear();
         graphics.beginFill(0,0);
         graphics.drawRect(0,0,width,height);
         graphics.endFill();
         var _loc4_:Number = 1;
         var _loc5_:Number = getStyle("dividerThickness");
         var _loc6_:Number = !!DividedBox(owner).isVertical() ? Number(DividedBox(owner).getStyle("verticalGap")) : Number(DividedBox(owner).getStyle("horizontalGap"));
         if(this.state != DividerState.DOWN)
         {
            if(_loc6_ >= 6)
            {
               if(!this.knob)
               {
                  if(_loc7_ = Class(getStyle("dividerSkin")))
                  {
                     this.knob = new _loc7_();
                  }
                  if(this.knob)
                  {
                     if(this.knob is ILayoutDirectionElement)
                     {
                        ILayoutDirectionElement(this.knob).layoutDirection = null;
                     }
                     addChild(this.knob);
                  }
               }
               if(this.knob)
               {
                  if(DividedBox(owner).isVertical())
                  {
                     this.knob.scaleX = 1;
                     this.knob.rotation = 0;
                  }
                  else
                  {
                     this.knob.scaleX = -1;
                     this.knob.rotation = -90;
                  }
                  this.knob.x = Math.round((width - this.knob.width) / 2);
                  this.knob.y = Math.round((height - this.knob.height) / 2);
               }
            }
            return;
         }
         _loc3_ = getStyle("dividerColor");
         _loc4_ = getStyle("dividerAlpha");
         graphics.beginFill(_loc3_,_loc4_);
         if(DividedBox(owner).isVertical())
         {
            if((_loc8_ = _loc5_) > _loc6_)
            {
               _loc8_ = _loc6_;
            }
            _loc9_ = (height - _loc8_) / 2;
            graphics.drawRect(0,_loc9_,width,_loc8_);
         }
         else
         {
            if((_loc10_ = _loc5_) > _loc6_)
            {
               _loc10_ = _loc6_;
            }
            _loc11_ = (width - _loc10_) / 2;
            graphics.drawRect(_loc11_,0,_loc10_,height);
         }
         graphics.endFill();
      }
      
      override public function styleChanged(param1:String) : void
      {
         super.styleChanged(param1);
         if(!param1 || param1 == "dividerSkin" || param1 == "styleName")
         {
            if(this.knob)
            {
               removeChild(this.knob);
               this.knob = null;
            }
         }
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         this.isMouseOver = true;
         if(!DividedBox(owner).activeDivider)
         {
            this.state = DividerState.OVER;
            DividedBox(owner).changeCursor(this);
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         this.isMouseOver = false;
         if(!DividedBox(owner).activeDivider)
         {
            this.state = DividerState.UP;
            if(parent)
            {
               DividedBox(owner).restoreCursor();
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         DividedBox(owner).changeCursor(this);
         DividedBox(owner).startDividerDrag(this,param1);
         var _loc2_:DisplayObject = systemManager.getSandboxRoot();
         _loc2_.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         _loc2_.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseUpHandler);
      }
      
      private function mouseUpHandler(param1:Event) : void
      {
         if(!this.isMouseOver)
         {
            DividedBox(owner).restoreCursor();
         }
         this.state = DividerState.OVER;
         DividedBox(owner).stopDividerDrag(this,param1 as MouseEvent);
         var _loc2_:DisplayObject = systemManager.getSandboxRoot();
         _loc2_.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,true);
         _loc2_.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE,this.mouseUpHandler);
      }
   }
}
